Failed tests \
LOCAL: 

modules:
- decontamination SE \
error 
```.command.sh: line 2: null: command not found```

subwfs: 
- qc SE 
error 
```.command.sh: line 2: null: command not found```
- 
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