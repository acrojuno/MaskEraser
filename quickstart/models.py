from django.db import models

# Create your models here.
class Post(models.Model):
    title = models.CharField(max_length=200)
    text = models.TextField()
    #년도->월->일 경로로 이미지가 저장됨
    image = models.ImageField(upload_to="%Y/%m/%d")
