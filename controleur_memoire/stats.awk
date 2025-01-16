BEGIN {
        # 110 registres du wrapper à enlever 
        REG_OFFSET=110
    }

/5\.56/ {OK=1;MISTRAL["ALUT"]=0;MISTRAL["ALUT_ARITH"]=0;MISTRAL["FF"]=0;MISTRAL["M10K"]=0;MISTRAL["MLAB"]=0}
/5\.57/ {OK=0}
/MISTRAL_ALUT_ARITH/ {if(OK) {MISTRAL["ALUT_ARITH"]=$2;NEXT}}
/MISTRAL_ALUT/ {if(OK) {MISTRAL["ALUT"]=MISTRAL["ALUT"]+$2}}
/MISTRAL_FF/ {if(OK) {MISTRAL["FF"]=$2-REG_OFFSET}}
/MISTRAL_M10K/ {if(OK) {MISTRAL["M10K"]=$2}}
/MISTRAL_MLAB/ {if(OK) {MISTRAL["MLAB"]=$2}}
END {
    for (key in MISTRAL) {
        printf("MISTRAL_%-10s%8d\n",key,MISTRAL[key])
    }
}
