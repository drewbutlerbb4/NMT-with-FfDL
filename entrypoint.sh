pip install --upgrade pip
pip uninstall -q -y torch torchvision
pip install cython
# Install Pytorch version 0.3.1
pip install http://download.pytorch.org/whl/cu90/torch-0.3.1-cp36-cp36m-linux_x86_64.whl
pip install torchvision
git clone https://github.com/OpenNMT/OpenNMT-py

cd OpenNMT-py
# Revert to OpenNMT Release for Pytorch 0.3.1
git checkout tags/v0.1
pip install -r requirements.txt
