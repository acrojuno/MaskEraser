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


def maskEraser(userId, n) :
    configuration = Configuration()
    dg = DataGenerator(configuration)

    model_h5_path = configuration.get('model_h5_path')
    model = Mask2FaceModel.load_model(model_h5_path)        
    
        
    input_imgs = dg.get_dataset_examples(userId, n, test_dataset=False)
    
    server_media_path = configuration.get('server_media_path')
    data_path =  server_media_path + userId + 'output'
    """
    #output_imgs = []
    for img in range(input_imgs):
        processed = model.predict(img)
        processed.save(data_path, 'PNG')
    """
    

    




class PostViewSet(viewsets.ModelViewSet):
    queryset = Mask2faceDB.objects.all()
    serializer_class = M2Fserializer
    #test = Mask2faceDB.objects.get('userId')
    #maskEraser(test, 1)
        

    
