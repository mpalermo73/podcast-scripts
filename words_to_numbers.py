#!/usr/bin/env python3


import sys
from word2number import w2n


if len(sys.argv) != 2:
  print("need word only word: \" "+ str(len(sys.argv)) +"\"")
  quit()

# print(sys.argv)
# print(w2n.word_to_num("two million three thousand nine hundred and eighty four"))
# print(w2n.word_to_num("Twenty-Nine"))

print(w2n.word_to_num(str(sys.argv[1])))
