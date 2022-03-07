from rest_framework import serializers
from .models import Mask2faceDB

class Mask2face(models.Model):
    image = serializers.ImageField(use_url=True)

    class Meta:
        model = Mask2faceDB
        fields = ('userId', 'number', 'image')