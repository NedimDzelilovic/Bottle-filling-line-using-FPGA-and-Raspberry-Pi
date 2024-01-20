import RPi.GPIO as GPIO
from time import sleep

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
    
#deklaracija pinova za upravljanje smjerovima motora
IN1 = 16  # lijevi motor
IN2 = 18  # lijevi motor
IN3 = 22  # desni motor
IN4 = 36  # desni motor

GPIO.setup(IN1, GPIO.OUT, initial=GPIO.HIGH)
GPIO.setup(IN2, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(IN3, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(IN4, GPIO.OUT, initial=GPIO.HIGH)

#deklaracija pinova za upravljanje brzinom motora
EN1 = 12  # lijevi motor ARNES ESP
EN2 = 32  # desni motor NEDIM ESP

GPIO.setup(EN1, GPIO.OUT)
EN1_pwm = GPIO.PWM(EN1, 50)
EN1_pwm.start(10)

GPIO.setup(EN2, GPIO.OUT)
EN2_pwm = GPIO.PWM(EN2, 50)
EN2_pwm.start(10)

#deklaracija pinova za ir senzore za pracenje linije
ir_1 = 7    # prvi s lijeve strane
ir_2 = 11  # drugi s lijeve strane
ir_3 = 13  # drugi s desne strane
ir_4 = 15  # prvi s desne strane
GPIO.setup(ir_1, GPIO.IN)
GPIO.setup(ir_2, GPIO.IN)
GPIO.setup(ir_3, GPIO.IN)
GPIO.setup(ir_4, GPIO.IN)

#deklaracija pinova za ir senzore za detektovanje flasa
ir_flasa1 = 29
ir_flasa2 = 31
GPIO.setup(ir_flasa1, GPIO.IN)
GPIO.setup(ir_flasa2, GPIO.IN)

#deklaracija pina za servo motor
SERVO = 33
GPIO.setup(SERVO, GPIO.OUT)
SERVO_pwm = GPIO.PWM(SERVO, 50)  # vrijednost 50 uzeta sa vjezbi
SERVO_pwm.start(7)

#deklaracija pina za diodu
dioda = 37
GPIO.setup(dioda, GPIO.OUT, initial=GPIO.LOW)

# funkcija za kretanje naprijed
def move_forward():
    GPIO.output(IN1, GPIO.HIGH)
    GPIO.output(IN2, GPIO.LOW)
    GPIO.output(IN3, GPIO.LOW)
    GPIO.output(IN4, GPIO.HIGH)
    GPIO.output(dioda, GPIO.HIGH)

# funkcija za kretanje nazad
def move_backward():
    GPIO.output(IN1, GPIO.LOW)
    GPIO.output(IN2, GPIO.HIGH)
    GPIO.output(IN3, GPIO.HIGH)
    GPIO.output(IN4, GPIO.LOW)
    GPIO.output(dioda, GPIO.LOW)

# funkcija za skretanje desno
def turn_right():
    GPIO.output(IN1, GPIO.HIGH)
    GPIO.output(IN2, GPIO.LOW)
    GPIO.output(IN3, GPIO.HIGH)
    GPIO.output(IN4, GPIO.LOW)
    GPIO.output(dioda, GPIO.HIGH)

# funkcija za skretanje lijevo
def turn_left():
    GPIO.output(IN1, GPIO.LOW)
    GPIO.output(IN2, GPIO.HIGH)
    GPIO.output(IN3, GPIO.LOW)
    GPIO.output(IN4, GPIO.HIGH)
    GPIO.output(dioda, GPIO.HIGH)

# Stop
def stop():
    GPIO.output(IN1, GPIO.LOW)
    GPIO.output(IN2, GPIO.LOW)
    GPIO.output(IN3, GPIO.LOW)
    GPIO.output(IN4, GPIO.LOW)
    GPIO.output(dioda, GPIO.LOW)

#funkcija za pomjeranje nazad od trake i okretanje za 180°
def okreni():
    sleep(2)

    #okretanje, prvi dio
    GPIO.output(IN1, GPIO.LOW)
    GPIO.output(IN2, GPIO.LOW)
    GPIO.output(IN3, GPIO.HIGH)
    GPIO.output(IN4, GPIO.LOW)
    EN1_pwm.ChangeDutyCycle(0) 
    EN2_pwm.ChangeDutyCycle(35)
    sleep(1.6)

    #okretanje, drugi dio
    GPIO.output(IN1, GPIO.HIGH)
    GPIO.output(IN2, GPIO.LOW)
    GPIO.output(IN3, GPIO.LOW)
    GPIO.output(IN4, GPIO.LOW)
    EN1_pwm.ChangeDutyCycle(35) 
    EN2_pwm.ChangeDutyCycle(0)
    sleep(2.3)
    stop()
    
#funkcija za pomjeranje nazad nakon istovara i okretanje za 180°
def okreni2():
    # nazad
    sleep(2)
    move_backward()
    EN1_pwm.ChangeDutyCycle(30)
    EN2_pwm.ChangeDutyCycle(30)
    sleep(0.1)
    
    #okretanje, prvi dio
    GPIO.output(IN1, GPIO.LOW)
    GPIO.output(IN2, GPIO.HIGH)
    GPIO.output(IN3, GPIO.LOW)
    GPIO.output(IN4, GPIO.LOW)
    EN1_pwm.ChangeDutyCycle(35)
    EN2_pwm.ChangeDutyCycle(0) 
    sleep(2)

    #okretanje, drugi dio
    GPIO.output(IN1, GPIO.LOW)
    GPIO.output(IN2, GPIO.LOW)
    GPIO.output(IN3, GPIO.LOW)
    GPIO.output(IN4, GPIO.HIGH)
    EN1_pwm.ChangeDutyCycle(0) 
    EN2_pwm.ChangeDutyCycle(35)
    sleep(2.1)
    stop()
    sleep(1)

#istovar flasa, pomjeranje nazad i okretanje za 180°
def istovar():
    stop()
    EN1_pwm.ChangeDutyCycle(0)  # potrebno podesiti vrijednost
    EN2_pwm.ChangeDutyCycle(0)  # potrebno podesiti vrijednost
    sleep(1)
    SERVO_pwm.ChangeDutyCycle(5)
    sleep(2)  # dok servo spusta platformu
    SERVO_pwm.ChangeDutyCycle(7)
    sleep(1)  # dok servo podize platformu
    okreni2()

sleep(5)

while True:

    # citanje vrijednosti senzora
    val_ir_1 = GPIO.input(ir_1) 
    val_ir_2 = GPIO.input(ir_2)
    val_ir_3 = GPIO.input(ir_3) 
    val_ir_4 = GPIO.input(ir_4)  

    val_ir_flasa1 = GPIO.input(ir_flasa1)
    val_ir_flasa2 = GPIO.input(ir_flasa2) 

    #naprijed
    if val_ir_1 == 0 and val_ir_2 == 1 and val_ir_3 == 1 and val_ir_4 == 0:
        move_forward()
        EN1_pwm.ChangeDutyCycle(30)   
        EN2_pwm.ChangeDutyCycle(30)

    #nemoguci uslov
    elif (val_ir_1 == 0 and val_ir_2 == 1 and val_ir_3 == 0 and val_ir_4 == 0)\
            or (val_ir_1 == 0 and val_ir_2 == 0 and val_ir_3 == 1 and val_ir_4 == 0):
        turn_right()
        EN1_pwm.ChangeDutyCycle(30) 
        EN2_pwm.ChangeDutyCycle(30)  

    # blago lijevo skretanje
    elif val_ir_1 == 1 and val_ir_2 == 1 and val_ir_3 == 1 and val_ir_4 == 0:
        turn_right()
        EN1_pwm.ChangeDutyCycle(30)  
        EN2_pwm.ChangeDutyCycle(30)  

    # srednje lijevo skretanje
    elif val_ir_1 == 1 and val_ir_2 == 1 and val_ir_3 == 0 and val_ir_4 == 0:
        turn_right()
        EN1_pwm.ChangeDutyCycle(30)  
        EN2_pwm.ChangeDutyCycle(35)  

    # jako lijevo skretanje
    elif val_ir_1 == 1 and val_ir_2 == 0 and val_ir_3 == 0 and val_ir_4 == 0:
        turn_right()
        EN1_pwm.ChangeDutyCycle(30)  
        EN2_pwm.ChangeDutyCycle(40) 

    # blago desno skretanje
    elif val_ir_1 == 0 and val_ir_2 == 1 and val_ir_3 == 1 and val_ir_4 == 1:
        turn_left()
        EN1_pwm.ChangeDutyCycle(30)  
        EN2_pwm.ChangeDutyCycle(30) 

    # srednje desno skretanje
    elif val_ir_1 == 0 and val_ir_2 == 0 and val_ir_3 == 1 and val_ir_4 == 1:
        turn_left()
        EN1_pwm.ChangeDutyCycle(35) 
        EN2_pwm.ChangeDutyCycle(30) 

    # jako desno skretanje
    elif val_ir_1 == 0 and val_ir_2 == 0 and val_ir_3 == 0 and val_ir_4 == 1:
        turn_left()
        EN1_pwm.ChangeDutyCycle(40) 
        EN2_pwm.ChangeDutyCycle(30) 

    # čekanje flaša
    elif (val_ir_1 == 1 and val_ir_2 == 1 and val_ir_3 == 1 and val_ir_4 == 1 and val_ir_flasa1 == 1 and val_ir_flasa2 == 1) \
            or (val_ir_1 == 1 and val_ir_2 == 1 and val_ir_3 == 1 and val_ir_4 == 1 and val_ir_flasa1 == 0 and val_ir_flasa2 == 1) \
            or (val_ir_1 == 1 and val_ir_2 == 1 and val_ir_3 == 1 and val_ir_4 == 1 and val_ir_flasa1 == 1 and val_ir_flasa2 == 0):
       stop()

    # okretanje robota
    elif val_ir_1 == 1 and val_ir_2 == 1 and val_ir_3 == 1 and val_ir_4 == 1 and val_ir_flasa1 == 0 and val_ir_flasa2 == 0:
        okreni()

    # istovar flaša
    elif val_ir_1 == 0 and val_ir_2 == 0 and val_ir_3 == 0 and val_ir_4 == 0 and val_ir_flasa1 == 0 and val_ir_flasa2 == 0:
        istovar()

    else:
        stop()
