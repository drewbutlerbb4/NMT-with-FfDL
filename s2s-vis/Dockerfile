FROM pytorch/pytorch:latest
ADD ./ .
RUN pip install --upgrade pip
RUN pip install -U cython torchtext h5py connexion scikit-learn annoy
RUN pip install -U http://download.pytorch.org/whl/cu90/torch-0.3.1-cp36-cp36m-linux_x86_64.whl

RUN git clone https://github.com/HendrikStrobelt/Seq2Seq-Vis
RUN cd Seq2Seq-Vis && /bin/bash -c "source setup_cpu.sh"
RUN /bin/bash -c "source Seq2Seq-Vis/setup_onmt_custom.sh"

RUN pip install -r OpenNMT-py/requirements.txt
RUN pip install -U ./OpenNMT-py

# Update src, tgt, and model flags to your owns
RUN cd OpenNMT-py && mkdir s2s && sed -i s/"100)"/"500)"/g extract_context.py && python extract_context.py -src ../valid-article.txt -tgt ../valid-titler.txt -model ../model-vis.pt
RUN cp Seq2Seq-Vis/scripts/h5_to_faiss.py OpenNMT-py/s2s/h5_to_faiss.py
RUN conda install -y faiss-cpu -c pytorch
RUN cd OpenNMT-py/s2s && python h5_to_faiss.py -states states.h5 -data decoder_out -output decoder.faiss -stepsize 100
RUN cd OpenNMT-py/s2s && python h5_to_faiss.py -states states.h5 -data encoder_out -output encoder.faiss -stepsize 100

RUN sed -i "s#dict[\"], [\']w[\']#dict\", \'wb\'#g" OpenNMT-py/VisServer.py && sed -i 's#str(ix) + \" \" + w + \"\\n\"#str(str(ix) + \" \" + w + \"\\n\").encode(\"utf-8\")#g' OpenNMT-py/VisServer.py
RUN cd OpenNMT-py && sed -i s#"../S2Splay/model_api/processing/s2s_iwslt_ende/baseline-brnn.en-de.s154_acc_61.58_ppl_7.43_e21.pt"#"../model-vis.pt"# VisServer.py && python VisServer.py
RUN mv s2s.yaml OpenNMT-py/s2s/s2s.yaml && mv model-vis.pt OpenNMT-py/s2s/model-vis.pt
RUN sed -i s#"\[h\])"#"[h]), encoding=\'utf-8\'"# Seq2Seq-Vis/s2s/project.py

EXPOSE 8080

CMD ["python", "Seq2Seq-Vis/server.py", "--dir", "OpenNMT-py/s2s"]
