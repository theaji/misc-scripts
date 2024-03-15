#Extract DNA sequences from a string and transform them into RNA by replacing the nucleotides

seq = "tatgctttcc#tataggtctg#ctattcaatg"
dna_list = seq.split("#")
print(f"The DNA list is: {dna_list} \n")
print("Results: \n")

for dna in dna_list:
    rna = dna.replace("t","u")
    print(f"DNA: {dna} -> RNA: {rna}")

