############################################################
# Dockerfile to build Owl docker image
# Based on ryanrhymes/owl master branch
# By Liang Wang <liang.wang@cl.cam.ac.uk>
############################################################

FROM ocaml/opam2:ubuntu-16.04-ocaml-4.06.0
USER opam


##################### PREREQUISITES ########################

RUN sudo apt-get update
RUN sudo apt-get -y install git wget unzip aspcud m4 pkg-config gfortran
RUN sudo apt-get -y install camlp4-extra libshp-dev libplplot-dev
RUN sudo apt-get -y install libopenblas-dev liblapacke-dev

RUN opam update && opam switch 4.06.0 && eval $(opam config env)
RUN opam install -y oasis jbuilder ocaml-compiler-libs ctypes utop eigen plplot alcotest base stdio configurator


#################### SET UP ENV VARS #######################

ENV PATH /home/opam/.opam/4.06.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
ENV CAML_LD_LIBRARY_PATH /home/opam/.opam/4.06.0/lib/stublibs


################## INSTALL OWL LIBRARY #####################

ENV OWLPATH /home/opam/owl
RUN cd /home/opam && git clone https://github.com/ryanrhymes/owl.git
RUN sed -i -- 's/-lopenblas/-lopenblas -llapacke/g' $OWLPATH/src/owl/jbuild  # FIXME: hacking
RUN sed -i -- 's:/usr/local/opt/openblas/lib:/usr/lib/x86_64-linux-gnu/:g' $OWLPATH/src/owl/jbuild  # FIXME: hacking
RUN make -C $OWLPATH && make -C $OWLPATH install && make -C $OWLPATH test && make -C $OWLPATH clean


############## SET UP DEFAULT CONTAINER VARS ##############

RUN echo "#require \"owl_top\";; open Owl;;" >> /home/opam/.ocamlinit
WORKDIR $OWLPATH
ENTRYPOINT /bin/bash
