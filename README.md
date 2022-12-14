# Accent Recognition Multi-task System with Pretrained Features
## Environment
### Set up kaldi environment
```
git clone -b 5.4 https://github.com/kaldi-asr/kaldi.git kaldi
cd kaldi/tools/; make; cd ../src; ./configure; make
```
### Set up espnet environment
```
git clone https://github.com/espnet/espnet.git
cd espnet/tools/        # change to tools folder
ln -s {kaldi_root}      # Create link to Kaldi. e.g. ln -s home/theanhtran/kaldi/
```
### Set up Conda environment
```
./setup_anaconda.sh anaconda espnet 3.8   # Create a anaconda environmetn - espnet with Python 3.7.9
make TH_VERSION=1.10.1 CUDA_VERSION=11.3     # Install Pytorch and CUDA
. ./activate_python.sh; python3 check_install.py  # Check the installation
bash installers/install_fairseq.sh
bash installers/install_s3prl.sh
```
### Set your own execution environment
Open path.sh file, change $MAIN_ROOT$ to your espnet directory, 
```
e.g. MAIN_ROOT=/home/lirui/espnet
```
## Data preparation
  1. All the data used in the experiment are stored in the `data` directory, in which train is used for training, valid is the verification set, 
    cv_all and test are used for testing respectively.
  2. In order to better reproduce my experimental results, you can download the data set first, and then directly change the path in `wav.scp` in different sets in `data` directory. <br>
  You can also use the `sed` command to replace the path in the wav.scp file with your path.
```
egs: 
origin path: /home/zhb502/raw_data/2020AESRC/American_English_Speech_Data/G00473/G00473S1002.wav
your path: /home/jicheng/ASR-data/American_English_Speech_Data/G00473/G00473S1002.wav
sed -i "s#/home/zhb502/raw_data/2020AESRC/#/home/jicheng/ASR-data/#g" data/train/wav.scp
```
3. Other files can remain unchanged, you can use it directly (eg, utt2IntLabel, text, utt2spk...).

### Add noise to the test set 
To test the performance in the noise background, we added musan noise to the test set.
At the same time, different SNR(5,10,15,20) are used for noise addition. <br>
#### Generate format file
```python
# The first parameter is the path to the musan noise audio
python deal_musan.py  /home3/jicheng/source-data/musan/noise data/musan_noise
```
### Add noise
```sh
cd Add-Noise
bash add-noise.sh --steps 2 --src-train ../data/test --noise_dir ../data/musan_noise
cd ..
bash generate_wav.sh
```

## Accent recognition system
  1. Model file preparation
    `run_asr_multitask_accent_recognition_16k.sh` and `run_asr_multitask_accent_recognition_8k.sh` are both used to train the multi-task model.<br>
    Before running, you need to first move the corresponding files of espnet to the corresponding directory of your espnet directory. 
```
eg: 
  move `espnet/asr/pytorch_backend/asr_train_multitask_accent.py` to ` your espnet localtion/espnet/asr/pytorch_backend/` 
  move `espnet/bin/*` to ` your espnet localtion/espnet/bin/` 
  move `espnet/nets/pytorch_backend/e2e_asr_transformer_multitask_accent.py` to ` your espnet localtion/espnet/nets/pytorch_backend/` 
  move `espnet/nets/pytorch_backend/transformers/encoder_inter_no_norm.py` to `your espnet localtion/espnet/nets/pytorch_backend/transformer/`
  move `espnet/utils/*` to ` your espnet localtion/espnet/utils/` 
```
  2. step by step
    The overall code is divided into four parts, including feature extraction, JSON file generation, model training and decoding. You can control the steps by changing the value of the step variable.<br>
  3. Download pretrained model<br>
    First you need to download the pretrained model to the pretrained-model folder, the download link is as follows:<br>
    - wavlm_large
        https://drive.google.com/file/d/12-cB34qCTvByWT-QtOcZaqwwO21FLSqU/view?usp=share_link<br>
    - xlsr53 
        https://dl.fbaipublicfiles.com/fairseq/wav2vec/xlsr_53_56k.pt
```
egs: 
  ### for 16k data
  #The pre-trained features are extracted in the first step, you can use model_type to decide to use wavlm or wav2vec2
  bash run_asr_multitask_accent_recognition_16k.sh --nj 20 --steps 1 --model_type wavlm
  bash run_asr_multitask_accent_recognition_16k.sh --nj 20 --steps 2
  bash run_asr_multitask_accent_recognition_16k.sh --nj 20 --steps 3
  bash run_asr_multitask_accent_recognition_16k.sh --nj 20 --steps 4
  bash run_asr_multitask_accent_recognition_16k.sh --nj 20 --steps 5
  bash run_asr_multitask_accent_recognition_16k.sh --nj 20 --steps 6
  ```
  4. For pretrained model trained on 16k data, you can download from this link: https://drive.google.com/file/d/1xqsRHQi7IrlYYekDK6tysbkEQNYtGirE/view?usp=share_link  <br>
     You can run the following command to directly reproduce our results.
```
  # 16k data
  bash run_asr_multitask_accent_recognition_16k.sh --nj 20 --steps 7 

```


