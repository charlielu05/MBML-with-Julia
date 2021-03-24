FROM julia:1.6.0

RUN apt-get update && apt install -y graphviz
RUN julia -e 'import Pkg; Pkg.add("ForneyLab"); using ForneyLab'