from collections import Counter

text = "Ronaldo, widely acclaimed as one of the two best players in the world along with Lionel Messi, threw himself at the ball after four minutes and powered the ball into the net for his fourth goal of the tournament." \
"His prolific scoring so far has put him on course to rival the extraordinary single-World Cup record of France?s Just Fontaine, who scored 13 times during the 1958 tournament. Fontaine's mark is thought likely never to be broken given the lower rate of scoring in modern World Cups."\
"Fontaine is not widely known to a present-day audience, as his superb 1958 performance was followed by a string of injuries that curtailed his career. He played his last game for France two years later and was retired from the sport by 1962."\
"Ronaldo, 33, will play in five more matches if Portugal makes it through to the semifinal stage. Obviously it's still early but If Ronaldo were able to maintain his current rate of two goals per game, he would finish the tournament with 14."\

words = text.split()

counter = Counter(words)
top_three = counter.most_common(3)
print(top_three)
