from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.shortcuts import redirect
from .models import ScoreTable
from django.core import serializers
from django.views.decorators.csrf import ensure_csrf_cookie
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from django.views.generic.edit import FormView, CreateView
# Create your views here.

@login_required
def index(request):
    if (request.method=="GET"):
        print(request)
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

@login_required
def table_details(request, slug):
    if 'month' and 'year' in request.GET:
        month_value = request.GET.get("month")
        year_value = request.GET.get("year")
        userID = request.user.username
        data=ScoreTable.objects.filter(date__month=month_value, date__year=year_value,userID=userID).values('id', 'score', 'date');
        return JsonResponse({'item': list(data)})

    data=ScoreTable.objects.all().values('id', 'score','date')
    return JsonResponse({'item': list(data)})

@login_required
@ensure_csrf_cookie
def table_write(request):
    if (request.method=="GET"):
        return JsonResponse({})

    score = request.POST["score"]
    date = request.POST["date"]
    userID = request.user.username
    print(userID)

    try:
        updateObj = ScoreTable.objects.get(date=date,userID=userID)
        updateObj.score = score
        updateObj.save()
    except ScoreTable.DoesNotExist:
        newObj = ScoreTable(score=score,date=date,userID = userID)
        newObj.save()
    return render(request,"sample/sample.html")

def auth(request):
    return render(request, "sample/auth.html")


class UserSingUp(CreateView):
    template_name = 'sample/signup.html'
    form_class = UserCreationForm
    success_url = 'signup'
