# om_inversions
Optical Mapping inversion detection and validation

## Background

* Recurrent CNV regions in genome - often lead to inversions

* Arrays typically call these; sequencing typically cannot due to large segmental duplications

* Arrays not great resolution, though, so use optical mapping

## Results

### 8p

* Recurrent CNV Location (hg19): chr8:8,100,064-11,766,329

### 17q

* Recurrent CNV Location (hg19): chr17:43,705,166-44,164,880

## Methods

### Automated Validation Discovery

* Use segmental duplication track to determine unique genomic regions

* Unique defined as region where molecule maps only to this location, given the alignment parameters, and nowhere else

### Inversion Discovery and Validation Pipeline

* Code provided as Snakemake workflow 
