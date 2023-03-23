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
- cmsearch [1]
- decontamination [3]
- extract models [1]

subwfs: 
- qc PE swapping files in snapshot?
- qc SE failed with decontamination

DB:

- decontamination_download.nf.test 
error 
```java.lang.OutOfMemoryError: Required array size too large```
- mapseq_download.nf.test 
error 
```java.lang.OutOfMemoryError: Required array size too large```