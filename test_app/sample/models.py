from django.db import models

# Create your models here.
class ScoreTable(models.Model):
    score=models.CharField(max_length=100)
    date=models.DateField()
    userID=models.CharField(max_length=100,default='')

    def __str__(self):
        return '<date:id=' + str(self.id) + ', ' + \
            str(self.date) + '(' + str(self.score) + ')' + self.userID + '>'
