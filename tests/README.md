Failed tests \
LOCAL:

DB:
- decontamination_download.nf.test
error
```java.lang.OutOfMemoryError: Required array size too large```
- mapseq_download.nf.test
error
```java.lang.OutOfMemoryError: Required array size too large```

CODON: \
modules:
- cmsearch [1] incorrect output bytes because of command inside output file

fixed but not beautiful :(
- extract models [1] incorrect order of output files in snapshot

subwfs: 
- qc swapping files in snapshot?

DB:

- decontamination_download.nf.test 
error 
```java.lang.OutOfMemoryError: Required array size too large```
- mapseq_download.nf.test 
error 
```java.lang.OutOfMemoryError: Required array size too large```