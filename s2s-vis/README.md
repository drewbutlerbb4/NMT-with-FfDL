# Analyze your OpenNMT model with Seq2Seq-Vis

In this section, we will use [a visual debugging tool for Sequence-to-Sequence models](https://github.com/HendrikStrobelt/Seq2Seq-Vis) to help us analyze and better understand our OpenNMT model.

### Prerequisites

* [Docker](https://www.docker.com/): You need to have your Docker running with at least 4 CPUs and 8 GB of memory. In addition, you need at least 30 GB in the Docker disk.

* *OpenNMT Model*: You can use the OpenNMT model from the previous section or download a pre-trained model from [NMT's PyTorch models](http://opennmt.net/Models-py/).

* *Sample source and target file*: You need to have some sample source and target file for your OpenNMT model to create a better Beamsearch tree and attention view.

### Create and run the Docker container for Seq2Seq-Vis Webapp.

0. Clone and move to this repository.

```shell
git clone https://github.com/drewbutlerbb4/NMT-with-FfDL
cd NMT-with-FfDL/s2s-vis
```

1. Move your OpenNMT model to this directory and name it `model-vis.pt` or download the sample model at http://sample-models.s3-api.us-geo.objectstorage.softlayer.net/model-vis.pt

2. Build the Docker container. Note that this build process takes around 90 minutes for 4 CPUs machine because it needs to set up the environment and do some intensive feature extractions with your model.

```shell
docker build -t s2s-vis:latest .
```

3. Run the Docker container and expose the webapp to your localhost's 8080 port.

```shell
docker run -p 8080:8080 s2s-vis:latest
```

4. Go to http://localhost:8080 and start play around with your model. You can visit http://seq2seq-vis.io/ for more info on how to use this Visual Debugging Tool.
