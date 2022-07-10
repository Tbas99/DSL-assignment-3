fact = 1
print("Enter an integer: ")
n = int(input())

if n < 0:
    print("Error! Factorial of a negative number doesn't exist.")
else:
    i = 1
    while True:
        i = i + 1
        if not (i <= n):
            break
        fact = fact * i
        
    print("Factorial of " + str(n) + " = " + str(fact))
