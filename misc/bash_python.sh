#!/bin/bash

echo "Please answer the following questions with 'yes' or 'no'."

use_bash=true

# Question 1
read -p "Is the problem easy to solve? (yes/no): " ans1
if [ "$ans1" != "yes" ]; then
    use_bash=false
fi

# Question 2
read -p "Do you need to do math beyond simple addition or multiplication? (yes/no): " ans2
if [ "$ans2" == "yes" ]; then
    use_bash=false
fi

# Question 3
read -p "Do you need concurrency? (yes/no): " ans3
if [ "$ans3" == "yes" ]; then
    use_bash=false
fi

# Question 4
read -p "Do you need data structures? (yes/no): " ans4
if [ "$ans4" == "yes" ]; then
    use_bash=false
fi

# Question 5
read -p "Do you need functional programming code style? (yes/no): " ans5
if [ "$ans5" == "yes" ]; then
    use_bash=false
fi

# Question 6
read -p "Do you need to work on Windows? (yes/no): " ans6
if [ "$ans6" == "yes" ]; then
    use_bash=false
fi

# Question 7
read -p "Do you care about performance? (yes/no): " ans7
if [ "$ans7" == "yes" ]; then
    use_bash=false
fi

# Conclusion
if [ "$use_bash" == "true" ]; then
    echo "Based on your answers, you can use a Bash script."
else
    echo "Based on your answers, you should consider using Python."
fi
