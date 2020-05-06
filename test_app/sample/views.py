from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.shortcuts import redirect
from .models import ScoreTable
from django.core import serializers
from django.views.decorators.csrf import ensure_csrf_cookie
# Create your views here.

def index(request):
    if (request.method=="GET"):
        return render(request,"sample/sample.html")
#    elif(request.method=="POST"):
#        score=request.POST["score"]
#        date=request.POST["date"]
#        scoreTable=ScoreTable(score=score,date=date)
#        scoreTable.save()
#        return render(request,"sample/sample.html")

def table(request):
    data=ScoreTable.objects.all()
    params={
        "title":"table",
        "data":data,
    }
    return render(request,"sample/table.html",params)

def table_details(request, slug):
    if 'month' and 'year' in request.GET:
        month_value = request.GET.get("month")
        year_value = request.GET.get("year")
        data=ScoreTable.objects.filter(date__month=month_value, date__year=year_value).values('id', 'score', 'date');
        return JsonResponse({'item': list(data)})

    data=ScoreTable.objects.all().values('id', 'score','date')
    return JsonResponse({'item': list(data)})

@ensure_csrf_cookie
def table_write(request):
    if (request.method=="GET"):
        return JsonResponse({})

    score=request.POST["score"]
    date=request.POST["date"]

    try:
        updateObj = ScoreTable.objects.get(date=date)
        updateObj.score = score
        updateObj.save()
    except ScoreTable.DoesNotExist:
        newObj = ScoreTable(score=score,date=date)
        newObj.save()
    return render(request,"sample/sample.html")
