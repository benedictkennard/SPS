#1. fill in this function
#   it takes a list for input and return a sorted version
#   do this with a loop, don't use the built in list functions
#   https://interactivepython.org/runestone/static/pythonds/SortSearch/TheBubbleSort.html
def sortwithloops(input):
    output = input
    for n in range(len(output) - 1, 0, -1):
        for i in range(n):
            if output[i] > output[i + 1]:
                temp = output[i]
                output[i] = output[i + 1]
                output[i + 1] = temp
    return output #return a value
	
#2. fill in this function
#   it takes a list for input and return a sorted version
#   do this with the built in list functions, don't us a loop
def sortwithoutloops(input):
    output = input
    output.sort()
    return output #return a value

#3. fill in this function
#   it takes a list for input and a value to search for
#   it returns true if the value is in the list, otherwise false
#   do this with a loop, don't use the built in list functions
def searchwithloops(input, value):
    for i in range(1, len(input)):
        if value == input [i]:
            output = True
            break
        else:
            output = False
    return output #return a value

#4. fill in this function
#   it takes a list for input and a value to search for
#   it returns true if the value is in the list, otherwise false
#   do this with the built in list functions, don't use a loop
def searchwithoutloops(input, value):
    output = value in input
    return output #return a value	

if __name__ == "__main__":
    L = [5,3,6,3,13,5,6]
    Q = [1,5,8,9,2]

    print sortwithloops(L) # [3, 3, 5, 5, 6, 6, 13]
    print sortwithoutloops(L) # [3, 3, 5, 5, 6, 6, 13]
    print searchwithloops(L, 5) #true
    print searchwithloops(L, 11) #false
    print searchwithoutloops(L, 5) #true
    print searchwithoutloops(L, 11) #false
