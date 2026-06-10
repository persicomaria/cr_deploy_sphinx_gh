# An overview of KofamKOALA

KofamKOALA (often referred to as KOfam) is a KEGG Ortholog (KO) assignment tool that identifies the function of gene/protein sequences 
by comparing them against a database of profile Hidden Markov Models (pHMMs).
The basic principles of Kofam are: 
## Profile HMM Database (KOfam)
 Instead of using simple sequence alignment (like BLAST), Kofam uses a library of HMM profiles, where each profile represents a 
specific KO family (a group of orthologous genes).
## Adaptive Score Thresholds
 Each pHMM in the database has a specific, pre-computed score threshold (``T``).
 These thresholds are not universal; they are individually determined for each KO family to maximize the balance between sensitivity and specificity.
## HMMER/hmmsearch
Kofam utilizes hmmsearch to compute bit scores, which measure the similarity between query sequences and the HMM profiles.

## High-Confidence Assignment
 A query sequence is assigned a KO number if the score exceeds the pre-defined threshold for that HMM. Assignments that pass this threshold are considered highly reliable and 
are often highlighted in the output.

## High Efficiency and Accuracy: 

By using HMMs with tailored thresholds, Kofam is significantly faster than previous tools like GhostKOALA, while maintaining a high level of accuracy comparable to 
top-performing tools. 

## How Thresholds are Determined
To create the adaptive threshold ``T``, non-redundant sequences of a KO family are split into groups, and a pHMM is built from some groups while others are used to test 
the model's accuracy, with the threshold maximizing the F-measure (average of precision and recall).
