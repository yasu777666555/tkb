from django.shortcuts import render
from django.http import HttpResponse
from django.shortcuts import redirect
from .models import ScoreTable
# Create your views here.

def index(request):
    if (request.method=="GET"):
        return render(request,"sample/sample.html")
    elif(request.method=="POST"):
        score=request.POST["score"]
        date=request.POST["date"]
        scoreTable=ScoreTable(score=score,date=date)
        scoreTable.save()
        return render(request,"sample/sample.html")

def table(request):
    data=ScoreTable.objects.all()
    params={
        "title":"table",
        "data":data,
    }
    return render(request,"sample/table.html",params)
