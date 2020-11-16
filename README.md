# om_inversions
Optical Mapping inversion detection and validation

## Background

* Recurrent CNV regions in genome - often lead to inversions

* WGS prevalent but cannot detect or validate these inversions due to the presence of segmental duplications within and surrounding the breakpoints

* FISH and other methods detect these inversions but their resolution is poor (i.e., breakpoint range estimates rather than bp-level or slightly above resolution)

* Solution: use optical mapping

* Optical mapping will not obtain bp-resolution either but is better resolution and can assemble the entire genomic region

* Thus, we can valuable info on the CNVs/SVs of the region along with the mapped haplotypes and better resolution of breakpoints

### 8p Inversion

* Recurrent CNV Location (hg19): chr8:8,100,064-11,766,329

* InvFEST approximate inversion coordinates: chr8:6,922,488-12,573,597

### 17q Inversion

* Recurrent CNV Location (hg19): chr17:43,705,166-44,164,880

* InvFEST approximate inversion coordinates: chr17:43,573,202-44,784,489

## Methods

### Automated Validation Discovery

* Use segmental duplication track to determine unique genomic regions

* Unique defined as region where molecule maps only to this location, given the alignment parameters, and nowhere else

* Pic of BNG ref with SDs on top

* Split-mapping to obtain inversions: Explain how use split-map

* Pic of ref, regular non-split molecule, split molecule to explain what split map is and how it finds an inversion

* Explain that b/c data quality (missing labels) and/or HET inversions (w/ diff breakpoints), consider all split loci; have to do this anyway b/c split maps do not indicate an explicitly consistent breakpoint per sample, anyway

* Obtain and enumerate all breaks per sample

* Pic of a sample with all split breaks

### Inversion Discovery and Validation Pipeline

* __Work in Progress:__ Code provided as Snakemake workflow 

## Results

* Work in Progress.
