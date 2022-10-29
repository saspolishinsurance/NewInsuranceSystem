#!/usr/bin/env python
# coding: utf-8

# In[4]:


#pip install pygame -- !!trzeba puścić jeśli nie jest już zainstalowane!!
import pygame
import random

#parametry tablicy - standardowe
BOARD_SIZE = 400
RED = (255, 0, 0)
GREEN = (0, 255, 0)
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

def main():
    # inicjalizacja pygame
    pygame.init()
    pygame.display.set_caption("Snake - Anna Michalik SGH")  #podpis gry na górze planszy 
    board = pygame.display.set_mode((BOARD_SIZE, BOARD_SIZE)) # rozmiar planszy to 400x400

    snake = Snake(200, 200, 10, 10) #korzystam z klasy Snake(self,x,y,w,h)
    fruit = Fruit()

    # definicja fontu dla wyniku gracza
    font = pygame.font.SysFont("txt", 25)

    score = 0

    # pętla gry, trwa dopóki gracz gra. Każda iteracja to jeden ruch węża
    # bez pętli 'while', powyższa plansza by się pojawiła, ale od razu zamknęła
    run = True
    while run:
        # spowalania odświeżanie ekranu, przez co wąż wolniej się porusza
        pygame.time.delay(100)

        # obsługa przycisku [X] - wyjścia z gry ('x' w prawym górnym rogu)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
 
        # pobieram informacje o wciśniętych klawiszach
        keys = pygame.key.get_pressed()

        # obsluga klawisza escape (klikam escape i program się wyłącza)
        if keys[pygame.K_ESCAPE]:
            run = False

        # obsluga sterowania wężem - odniesienie do wciśniętego klawisza
        if keys[pygame.K_LEFT]:
            snake.change_direction("left")
        elif keys[pygame.K_RIGHT]:
            snake.change_direction("right")
        elif keys[pygame.K_UP]:
            snake.change_direction("up")
        elif keys[pygame.K_DOWN]:
            snake.change_direction("down")
        
        # ruch węża o jedno pole (poniżej są klasy do użytych tu metod)
        snake.move()

        # jeżeli wąż wyjedzie poza ekran to pojawi się z drugiej strony
        snake.check_borders()

        # w przypadku kolizji z ogonem gra jest kończona
        if snake.check_collision():
            run = False

        # aktualizacja ogona wężą
        snake.update_tail()
        
        # zjedzony owoc skutkuje podwyższeniem wyniku oraz wydłużeniem ogona
        # generowana jest nowa pozycja dla owocu
        if snake.has_eaten_fruit((fruit.x, fruit.y)):
            score += 1 #zwiększenie wyniku
            snake.add_to_tail((fruit.x, fruit.y)) #wydłużenie ogona
            fruit.generate_position()  #nowa losowa pozycja owocu

        # pokaż wyniki na ekranie
        text = font.render(f"Score: {score}" , True, WHITE) #aktualny wynik węża (liczba zjedzoncy owoców)
        board.blit(text, (0, BOARD_SIZE - 25)) #położenie na ekranie wyniku

        # odświeżenie lokalizacji obiektów na ekranie
        snake.draw(board)
        fruit.draw(board)

        # odświeżenie ekranu
        pygame.display.update()
        board.fill(BLACK)
    pygame.quit()
    
#schemat gry został przedstawiony, poniżej dodaję metody obiektów używając klas, które są używane w grze

class Fruit:
    def __init__(self):
        self.x = 0 #współrzędna x owoca
        self.y = 0 #współrzędna y owoca
        self.generate_position()

        self.w = 10 #szerokość owocu
        self.h = 10 #wysokość owocu (kwadrat 10x10)
        self.eaten = False

    def generate_position(self):
        
        #Generuję losową pozycję dla owocu na ekranie używając biblioteki 'random'
        
        self.x = random.randrange(0, BOARD_SIZE, 10)
        self.y = random.randrange(0, BOARD_SIZE, 10)
        #print(self.x, self.y) #drukuje nową pozycję owocu

    def draw(self, board):
        
        #Rysuje na ekranie koło reprezentujące owoc - czerwone jabłko.
        
        pygame.draw.rect(board, RED, (self.x, self.y, self.w, self.h))


class Snake:
    def __init__(self, x, y, w, h):
        self.x = x #współrzędna x w której pojawia się jednoelementowy wąż (potem będzie to 'głowa' węża)
        self.y = y #współrzędna y w której pojawia się jednoelementowy wąż
        self.w = w # u nas wyżej jest to ustalone jako 200,200,10,10
        self.h = h
        self.speed = 10 #stała prędkość węża, można zwiększyć/zmniejszyć, ale ta wydaje się optymalna
        self.direction = "down" #po otwarciu programu, wąż rusza do dołu
        self.tail = [(self.x, self.y)]  #pozycja kolejnych kawałków ogonu

    def change_direction(self, new_direction):
        
        #Zmienia kierunek, w którym podąża wąż.
        #Wąż nie może zawrócić w miejscu tzn.:
        #jeżeli podąża w lewa stronę to nie może zacząć podążać w prawo
        
        if new_direction == "left" and self.direction != "right":
            self.direction = new_direction
        elif new_direction == "right" and self.direction != "left":
            self.direction = new_direction
        elif new_direction == "up" and self.direction != "down":
            self.direction = new_direction
        elif new_direction == "down" and self.direction != "up":
            self.direction = new_direction

    def check_borders(self):
        
        #Obsługuje kolizje węża z końcem ekranu. W przypadku, gdy
        #wąż wyjedzie poza ekran zostanie on przywrócony po drugiej
        #stronie planszy. Nie chcę, by gra się kończyła w momencie trafenia na brzeg ekranu.
        
        if self.x > BOARD_SIZE - self.speed: #gdy pozycja x dociera do prawego brzegu planszu
            self.x = 0               #to ustawiam pozycję na początek tej planszy z lewej strony
        elif self.x < 0:             #analogicznie jak wyżej
            self.x = BOARD_SIZE - self.speed
        elif self.y < 0:
            self.y = BOARD_SIZE - self.speed
        elif self.y > BOARD_SIZE - self.speed:
            self.y = 0

    def has_eaten_fruit(self, pos):
       
        #Sprawdza, czy aktualna pozycja węża nie pokrywa się z owocem (pierwszy element listy = przód węża)
        
        if (self.x, self.y) == pos:
            return True #jeśli pozycje się pokrywają, oznacza to, że wąż zjadł owoc
        return False

    def draw(self, board):
        
        #Rysuje na ekranie prostokąt reprezentujący zielonego węża.
        
        for pts in self.tail: #wąż składa się z 'kawałków ogonu'=prostokątów, więc maluję wszystkie kawałki
            pygame.draw.rect(board, GREEN, (pts[0], pts[1], self.w, self.h))  #kolejne współrzędne kawałków x i y

    def update_tail(self):
        
        #Aktualizuje ogon węża, reprezentowany jako lista.
        
        self.tail.pop(0)  #usuwa pierwszy element listy, czyli przód ogonu
        self.tail.append((self.x, self.y))  #dodaje nową pozycję - ostatni kawałek ogona
        #w ten sposób widzimy 'przesuwanie' się węża po wykonaniu ruchu 

    def move(self):
        
        #Zmienia pozycję węża o jedno pole (zmienna speed - zakładam że jedno pole to kwadrat 10x10)
        
        if self.direction == "left":  #jeśli wciśniemy klawisz strzałki 'w lewo'
            self.x -= self.speed      #to wspólrzędna x będzie się zmniejszała stale o 10 (o pole),
        elif self.direction == "right":  #analogicznie jak wyżej
            self.x += self.speed
        elif self.direction == "up":
            self.y -= self.speed
        elif self.direction == "down":
            self.y += self.speed

    def add_to_tail(self, pos):
        
        #Powiększa ogon węża o pozycję zjedzonego owoca.
       
        self.tail.insert(0, pos) 
        #tam gdzie wcześniej był owoc, teraz jest dodatkowy zielony kwadrat reprezentujący kawałek ogona

    def check_collision(self):
        
        #Sprawdza kolizje węża z własnym ciałem.
        
        if len(self.tail) == 1:  #dla ogonu długości jeden nie da się mieć kolizji
            return False
        for pt in self.tail:
            if (self.x, self.y) == pt: #jeśli głowa węża ma takie same współrzędne jak któryś z kawałków ogona
                return True
        return False

#jeżeli w trakcie działania funcji main pojawi się błąd, to zostanie on wyświetlony
if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(str(e))


# In[ ]:




