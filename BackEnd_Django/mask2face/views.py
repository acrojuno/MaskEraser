from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.request import Request
from rest_framework.response import Response
from .models import Mask2faceDB
from .serializers import M2Fserializer


import os
#import tarfile
#import tensorflow as tf

#matplotlib : 테스트용으로 이미지 띄울 때 필요함
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

from mask2face_master.utils import download_data
from mask2face_master.utils.configuration import Configuration
from mask2face_master.utils.data_generator import DataGenerator
#from utils.architectures import UNet
from mask2face_master.utils.model import Mask2FaceModel


def maskEraser(n) :
    model = Mask2FaceModel.load_model(r'C:\Users\junho\Documents\GitHub\django_test\BackEnd_Django\mask2face_master\models\model_epochs-20_batch-7_loss-ssim_l1_loss_20220202_17_50_38.h5')        
    configuration = Configuration()
    dg = DataGenerator(configuration)
        
    input_imgs = dg.get_dataset_examples(n, test_dataset=False)
    
    output_imgs = []
    for img in range(input_imgs):
        output_imgs.append(model.predict(img))

    return input_imgs, output_imgs



class PostViewSet(viewsets.ModelViewSet):
    queryset = Mask2faceDB.objects.all()
    serializer_class = M2Fserializer
        

    
