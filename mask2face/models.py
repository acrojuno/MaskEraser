from django.db import models

# Create your models here.

class Mask2faceDB(models.Model):
    userId = models.CharField(max_length=200)
    number = models.IntegerField(max_length=4)
    #년도->월->일 경로로 이미지가 저장됨
    image = models.ImageField(upload_to="uploads/")
