from django.db import models

# Create your models here.

def user_directory_path(instance, filename):
    return f'{instance.userId}/input/{filename}'

class Mask2faceDB(models.Model):
    userId = models.CharField(max_length=200)
    image = models.ImageField(upload_to = user_directory_path)
    quantity = models.IntegerField(null=True)