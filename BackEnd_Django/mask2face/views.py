from email.mime import image
from django.shortcuts import render
from rest_framework import viewsets
from rest_framework.views import APIView
#from rest_framework.request import Request
from rest_framework.response import Response
from .models import Mask2faceDB
from .serializers import M2Fserializer


import os

from mask2face_master.utils import download_data
from mask2face_master.utils.configuration import Configuration
from mask2face_master.utils.data_generator import DataGenerator
from mask2face_master.utils.model import Mask2FaceModel


def maskEraser() :

    #마스크 제거(mask2face_master) 초기 세팅
    configuration = Configuration()
    dg = DataGenerator(configuration)

    
    #딥러닝 모델 파일 지정
    model_h5_path = configuration.get('model_h5_path')
    model = Mask2FaceModel.load_model(model_h5_path)


    #DB에서 가장 최근에 등록된 필드 값을 가져옴
    row = Mask2faceDB.objects.last()
    #가장 최근에 등록된 필드 값 중 유저ID를 가져와 'userId' 변수에 저장
    userId = row.userId
    
    #사용자가 업로드한 input 이미지의 경로와 파일명을 가져와 변수에 저장    
    input_imgs, file_names = dg.get_dataset_path(
        userId, n = 1, is_dataset_input = True, get_file_names = True)
    
    #configuration.json 파일에 있는 본인 환경에 맞는 미디어 폴더 경로를 불러옴
    server_media_path = configuration.get('server_media_path')
    #마스크가 제거된 output 이미지가 저장 될 경로
    data_path =  server_media_path + userId + '/output/'
    #해당 경로가 존재하는지 확인(존재하지 않으면 자동으로 생성)
    checkDirectory(data_path)

    #input 이미지를 output 이미지로 변환시키고 파일명을 'output_기존파일명' 형식으로 저장 
    for img in input_imgs:
        output = model.predict(img)
        
        output.save(data_path + 'output_' + file_names[0], 'PNG')
        
    #방금 저장한 output 이미지의 경로를 불러옴
    output_imgs = dg.get_dataset_path(userId, n = 1, is_dataset_input = False)
    #위에서 불러온 필드 값 중 'output' 필드를 수정
    row.output = output_imgs[0]
    #필드 저장
    row.save()

#해당 경로가 존재하는지 확인(존재하지 않으면 자동으로 생성)
def checkDirectory(path):
    try:
        if not os.path.exists(path):
            os.makedirs(path)
    except OSError:
        print("Error: Failed to create the directory.")


class GetAPIView(APIView):
    #GET HTTP Method 요청이 왔을 때
    def get(self, request):
        #상단의 maskEraser 함수 실행
        maskEraser()
        #DB에서 가장 최근에 등록된 필드 값을 가져옴
        obj = Mask2faceDB.objects.last()
        #DB에 있는 필드 값을 JSON화 시킴
        serialized_obj = M2Fserializer(obj, context={'request' : request})
        #JSON으로 최종 응답함
        return Response(data = serialized_obj.data)


class PostViewSet(viewsets.ModelViewSet):
    queryset = Mask2faceDB.objects.all()
    serializer_class = M2Fserializer
    #maskEraser(Request, n = 1)
        

    
