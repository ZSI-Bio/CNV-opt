
#For running GATK's DepthOfCoverage in parallel, first split up your samples' list of BAMs into the desired degree of parallelism (in the example here, three files):
#group1.READS.bam.list
#group2.READS.bam.list
#group3.READS.bam.list


#Run GATK for depth of coverage (three times: once for samples in group1, once for group2, and once for group3):
java -Xmx3072m -jar ./Sting/dist/GenomeAnalysisTK.jar \
-T DepthOfCoverage -I group1.READS.bam.list -L EXOME.interval_list \
-R ./human_g1k_v37.fasta \
-dt BY_SAMPLE -dcov 5000 -l INFO --omitDepthOutputAtEachBase --omitLocusTable \
--minBaseQuality 0 --minMappingQuality 20 --start 1 --stop 5000 --nBins 200 \
--includeRefNSites \
--countType COUNT_FRAGMENTS \
-o group1.DATA

java -Xmx3072m -jar ./Sting/dist/GenomeAnalysisTK.jar \
-T DepthOfCoverage -I group2.READS.bam.list -L EXOME.interval_list \
-R ./human_g1k_v37.fasta \
-dt BY_SAMPLE -dcov 5000 -l INFO --omitDepthOutputAtEachBase --omitLocusTable \
--minBaseQuality 0 --minMappingQuality 20 --start 1 --stop 5000 --nBins 200 \
--includeRefNSites \
--countType COUNT_FRAGMENTS \
-o group2.DATA

java -Xmx3072m -jar ./Sting/dist/GenomeAnalysisTK.jar \
-T DepthOfCoverage -I group3.READS.bam.list -L EXOME.interval_list \
-R ./human_g1k_v37.fasta \
-dt BY_SAMPLE -dcov 5000 -l INFO --omitDepthOutputAtEachBase --omitLocusTable \
--minBaseQuality 0 --minMappingQuality 20 --start 1 --stop 5000 --nBins 200 \
--includeRefNSites \
--countType COUNT_FRAGMENTS \
-o group3.DATA


#Combines GATK Depth-of-Coverage outputs for multiple samples (at same loci):
./xhmm --mergeGATKdepths -o ./DATA.RD.txt \
--GATKdepths group1.DATA.sample_interval_summary \
--GATKdepths group2.DATA.sample_interval_summary \
--GATKdepths group3.DATA.sample_interval_summary


#Optionally, run GATK to calculate the per-target GC content and create a list of the targets with extreme GC content:
java -Xmx3072m -jar ./Sting/dist/GenomeAnalysisTK.jar \
-T GCContentByInterval -L EXOME.interval_list \
-R ./human_g1k_v37.fasta \
-o ./DATA.locus_GC.txt

cat ./DATA.locus_GC.txt | awk '{if ($2 < 0.1 || $2 > 0.9) print $1}' \
> ./extreme_gc_targets.txt


#Optionally, run PLINK/Seq to calculate the fraction of repeat-masked bases in each target and create a list of those to filter out:
./sources/scripts/interval_list_to_pseq_reg EXOME.interval_list > ./EXOME.targets.reg

pseq . loc-load --locdb ./EXOME.targets.LOCDB --file ./EXOME.targets.reg --group targets --out ./EXOME.targets.LOCDB.loc-load

pseq . loc-stats --locdb ./EXOME.targets.LOCDB --group targets --seqdb ./seqdb | \
awk '{if (NR > 1) print $_}' | sort -k1 -g | awk '{print $10}' | paste ./EXOME.interval_list - | \
awk '{print $1"\t"$2}' \
> ./DATA.locus_complexity.txt

cat ./DATA.locus_complexity.txt | awk '{if ($2 > 0.25) print $1}' \
> ./low_complexity_targets.txt


#Filters samples and targets and then mean-centers the targets:
./xhmm --matrix -r ./DATA.RD.txt --centerData --centerType target \
-o ./DATA.filtered_centered.RD.txt \
--outputExcludedTargets ./DATA.filtered_centered.RD.txt.filtered_targets.txt \
--outputExcludedSamples ./DATA.filtered_centered.RD.txt.filtered_samples.txt \
--excludeTargets ./extreme_gc_targets.txt --excludeTargets ./low_complexity_targets.txt \
--minTargetSize 10 --maxTargetSize 10000 \
--minMeanTargetRD 10 --maxMeanTargetRD 500 \
--minMeanSampleRD 25 --maxMeanSampleRD 200 \
--maxSdSampleRD 150


#Runs PCA on mean-centered data:
./xhmm --PCA -r ./DATA.filtered_centered.RD.txt --PCAfiles ./DATA.RD_PCA


#Normalizes mean-centered data using PCA information:
./xhmm --normalize -r ./DATA.filtered_centered.RD.txt --PCAfiles ./DATA.RD_PCA \
--normalizeOutput ./DATA.PCA_normalized.txt \
--PCnormalizeMethod PVE_mean --PVE_mean_factor 0.7


#Filters and z-score centers (by sample) the PCA-normalized data:
./xhmm --matrix -r ./DATA.PCA_normalized.txt --centerData --centerType sample --zScoreData \
-o ./DATA.PCA_normalized.filtered.sample_zscores.RD.txt \
--outputExcludedTargets ./DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_targets.txt \
--outputExcludedSamples ./DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_samples.txt \
--maxSdTargetRD 30


#Filters original read-depth data to be the same as filtered, normalized data:
./xhmm --matrix -r ./DATA.RD.txt \
--excludeTargets ./DATA.filtered_centered.RD.txt.filtered_targets.txt \
--excludeTargets ./DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_targets.txt \
--excludeSamples ./DATA.filtered_centered.RD.txt.filtered_samples.txt \
--excludeSamples ./DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_samples.txt \
-o ./DATA.same_filtered.RD.txt


#Discovers CNVs in normalized data:
./xhmm --discover -p ./params.txt \
-r ./DATA.PCA_normalized.filtered.sample_zscores.RD.txt -R ./DATA.same_filtered.RD.txt \
-c ./DATA.xcnv -a ./DATA.aux_xcnv -s ./DATA


#NOTE: A description of the .xcnv file format can be found below.


#Genotypes discovered CNVs in all samples:
./xhmm --genotype -p ./params.txt \
-r ./DATA.PCA_normalized.filtered.sample_zscores.RD.txt -R ./DATA.same_filtered.RD.txt \
-g ./DATA.xcnv -F ./human_g1k_v37.fasta \
-v ./DATA.vcf

#And, the R visualization plots:


#Annotate exome targets with their corresponding genes:
pseq . loc-intersect --group refseq --locdb ./RefSeq.locdb --file ./EXOME.interval_list --out ./annotated_targets.refseq

#Plot the XHMM pipeline and CNV discovered:
#[ First, ensure that the R scripts are installed as described here ]

Rscript example_make_XHMM_plots.r
