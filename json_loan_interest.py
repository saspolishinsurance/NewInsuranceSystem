#!/usr/bin/env python
# coding: utf-8

# In[457]:


def odsetki(windxxx, lombard, należne):
    
    import os
    import json
    from datetime import date
    from datetime import datetime
    
    
    #wczytuję plik lombart i go oczyszczam
    with open(lombard) as f:
        mylist = [line.rstrip('\n') for line in f]
    
    rates =[]
    for i in mylist:
        rates.append(((i.split('\t'))))
        
    
    #wyciagam daty, aby potem policzyć dni między nimi
    dates = []
    for i in rates:
        dates.append(i[0])
    
    #wczytuję plik json
    with open(windxxx) as j:
        debtors = json.load(j)
    #nr sprawy, nazwy dłużnika, terminie i kwocie należności oraz sekwencji numerów telefonów.

    #usuwam rekordy, gdzie brakuje jakiegoś elementu
    for i in debtors:
        if len(i) != 5:
            debtors.remove(i)
    
    #usuwam numery telefonów bo są nam niepotrzebne
    for i in debtors:
        i.remove(i[4])
     
    
    #usuwam duplikaty spraw i wybieram nowszą sprawę
    for x in debtors:
        for y in debtors:
            if x[0]==y[0]:
                if int(x[2][0:4])>int(y[2][0:4]):
                    debtors.remove(y)
                elif int(x[2][0:4])==int(y[2][0:4]) and int(x[2][5:7])>int(y[2][5:7]):
                    debtors.remove(y)
                elif int(x[2][0:4])==int(y[2][0:4]) and int(x[2][5:7])==int(y[2][5:7]) and int(x[2][8:10])>int(y[2][8:10]):
                    debtors.remove(y)
    
    #liczę różnicę w datach, by obliczyć odsetki do dnia dzisiejszego
    lastdate = datetime.strptime(dates[0], '%Y-%m-%d')
    today = datetime.now()
    until_today0 = today - lastdate
    until_today = until_today0.days+1 #dodaje +1 bo on nie wlicza obecnego dnia

    #liczę dni między tymi datami
    days = [until_today]
    for i, j in zip(dates[:-1],dates[1:]):
        
        days_between = datetime.strptime(i, '%Y-%m-%d') - (datetime.strptime(j, '%Y-%m-%d'))
        
        days.append(days_between.days) 
    
    for i, j in zip(rates, days):
        i.append(j)
    
    for i in rates:
        i[1] = float(i[1].strip().replace('%',''))/100
    
    
    
    #LICZĘ ODSETKI
    odsetki_lista = []

    for i in debtors:

        date_i = i[2]
        rates_i = rates
        
        odsetki_i = 0

        for j in rates_i:

            if date_i < j[0]:
                #dzienna kwota odsetek = (stopa karnych odsetek/365) * kwota
                odsetki_period = (j[1]/365)*j[2]*i[3]
                odsetki_i = odsetki_i+odsetki_period 
                data_ostatnia = datetime.strptime(j[0], '%Y-%m-%d')
                data_zadluzenia = datetime.strptime(date_i, '%Y-%m-%d')
            else:
                dni_startowe = data_ostatnia - data_zadluzenia
                dni_start = dni_startowe.days

                odsetki_startowe = (j[1]/365)*i[3]*dni_start
                odsetki_total = round(odsetki_i + odsetki_startowe,2)
                break
        odsetki_lista.append(odsetki_total)
                                      
        
    
    #Podłączam odsetki do listy dłużników
    for i, j in zip(debtors, odsetki_lista):
        i.append(j)
            
    #Wczytuję plik json                                  
    with open(należne, 'w') as f:
        json.dump(debtors, f)       
        
    #odsetki('wind109.json', 'lombard.txt', 'należne.json') - przykładowe użycie funkcji

