---
title: 실무에서 바로 써먹는 Design Pattern - Strategy Pattern
category: design pattern
tags:
  - designpattern
---

## 단일 클래스로 작성

```python
class Animal:
    def __init__(self, name, species):
        self.name = name
        self.species = species

    def eat(self):
        if self.species == "Dog":
            return f"{self.name} is eating dog food."
        elif self.species == "Cat":
            return f"{self.name} is eating cat food."
        elif self.species == "Snake":
            return f"{self.name} is eating mouse."
        else:
            return f"{self.name} doesn't know what to eat."

    def sleep(self):
        if self.species == "Dog":
            return f"{self.name} is sleeping in a dog bed."
        elif self.species == "Cat":
            return f"{self.name} is sleeping on a cat tree."
        elif self.species == "Snake":
            return f"{self.name} is sleeping in a cozy corner."
        else:
            return f"{self.name} doesn't know where to sleep."

    def make_sound(self):
        if self.species == "Dog":
            return f"{self.name} says: Woof!"
        elif self.species == "Cat":
            return f"{self.name} says: Meow!"
        elif self.species == "Snake":
            return f"{self.name} says: Hiss!"
        else:
            return f"{self.name} doesn't make any sound."

# Creating instances of animals
dog = Animal("Buddy", "Dog")
cat = Animal("Whiskers", "Cat")
snake = Animal("Slinky", "Snake")

# Performing actions
print(dog.eat())        # Output: "Buddy is eating dog food."
print(cat.sleep())      # Output: "Whiskers is sleeping on a cat tree."
print(snake.make_sound())  # Output: "Slinky says: Hiss!"
```

## 상속을 이용한 개선

```python
class Animal:
    def __init__(self, name, species):
        self.name = name
        self.species = species

    def eat(self):
        pass

    def sleep(self):
        pass

    def make_sound(self):
        pass

class Dog(Animal):
    def eat(self):
        return f"{self.name} is eating dog food."

    def sleep(self):
        return f"{self.name} is sleeping in a dog bed."

    def make_sound(self):
        return f"{self.name} says: Woof!"

class Cat(Animal):
    def eat(self):
        return f"{self.name} is eating cat food."

    def sleep(self):
        return f"{self.name} is sleeping on a cat tree."

    def make_sound(self):
        return f"{self.name} says: Meow!"

class Snake(Animal):
    def eat(self):
        return f"{self.name} is eating mouse."

    def sleep(self):
        return f"{self.name} is sleeping in a cozy corner."

    def make_sound(self):
        return f"{self.name} says: Hiss!"

# Creating instances of animals
dog = Dog("Buddy", "Dog")
cat = Cat("Whiskers", "Cat")
snake = Snake("Slinky", "Snake")
unknown_animal = Unknown("Mystery", "Unknown")

# Performing actions
print(dog.eat())        # Output: "Buddy is eating dog food."
print(cat.sleep())      # Output: "Whiskers is sleeping on a cat tree."
print(snake.make_sound())  # Output: "Slinky says: Hiss!"
```

상속을 이용해서 개선해봤다. 훨씬 나아진 것 같다. 하지만 여전히 새로운 요구사항이 추가되면 여기저기 수정해야할 부분이 많다.

만약 고양이 로봇이 추가되어야하고, 고양이 로봇1은 하늘을 날 수 있고 고양이 로봇2는 잠을 자지 않고 고양이 로봇3는 잠도 자지 않고 하늘도 날 수 있다고 해보자.

```python
class Cat(Animal):
    def eat(self):
    return f"{self.name} is eating cat food."

    def sleep(self):
        return f"{self.name} is sleeping on a cat tree."

    def make_sound(self):
        return f"{self.name} says: Meow!"

class RobotCat(Cat):
    def sleep(self):
        return f"{self.name} is not sleeping."

    def fly(self):
        return f"{self.name} is flying."

class FlyableRobotCat(Cat):
    def sleep(self):
        return f"{self.name} is sleeping on a cat tree."

class SleeplessRobotCat(RobotCat):
    def sleep(self):
        return f"{self.name} is not sleeping."

    def fly(self):
        return f"{self.name} can't fly."

robot_cat_1 = FlyableRobotCat("Robot Cat 1", "FlyableRobotCat")
robot_cat_2 = SleeplessRobotCat("Robot Cat 2", "SleeplessRobotCat")
robot_cat_3 = RobotCat("Robot Cat 3", "RobotCat")

print(robot_cat_1.fly())      # Output: "Robot Cat 1 is flying."
print(robot_cat_2.sleep())    # Output: "Robot Cat 2 is not sleeping."
print(robot_cat_3.fly())      # Output: "Robot Cat 3 is flying."
print(robot_cat_3.sleep())    # Output: "Robot Cat 3 is not sleeping."
```

위 처럼 RobotCat 만들면 RobotCat class를 상속 받은 모든 child class에 각 특성에 따라 fly와 sleep을 override 해줘야한다. 만약, RobotCat class를 을 상속 받는 로봇 고양이들이 100개가 된다면? 그리고 특징이 추가 된다면? 그렇게 한달마다 새로운 고양이와 특징이 추가된다면? 생각만해도 끔찍하다...

```python
class Cat(Animal):
    def eat(self):
    return f"{self.name} is eating cat food."

    def sleep(self):
        return f"{self.name} is sleeping on a cat tree."

    def make_sound(self):
        return f"{self.name} says: Meow!"

class FlyableRobotCat(Cat):
    def fly(self):
        return f"{self.name} is flying."

class SleeplessRobotCat(Cat):
    def sleep(self):
        return f"{self.name} is not sleeping."

robot_cat_1 = FlyableRobotCat("Robot Cat 1", "FlyableRobotCat")
robot_cat_2 = SleeplessRobotCat("Robot Cat 2", "SleeplessRobotCat")

print(robot_cat_1.fly())    # Output: "Robot Cat 1 is flying."
print(robot_cat_2.sleep())  # Output: "Robot Cat 2 is not sleeping."
```

## 전략 패턴을 이용한 개선

```python
# Using Strategy pattern with Inheritance

class Behavior:
    def execute(self, name):
        pass

class EatBehavior(Behavior):
    def execute(self, name):
        pass

class SleepBehavior(Behavior):
    def execute(self, name):
        pass

class SoundBehavior(Behavior):
    def execute(self, name):
        pass

class DogEatBehavior(EatBehavior):
    def execute(self, name):
        return f"{name} is eating dog food."

class DogSleepBehavior(SleepBehavior):
    def execute(self, name):
        return f"{name} is sleeping in a dog bed."

class DogSoundBehavior(SoundBehavior):
    def execute(self, name):
        return f"{name} says: Woof!"

class CatEatBehavior(EatBehavior):
    def execute(self, name):
        return f"{name} is eating cat food."

class CatSleepBehavior(SleepBehavior):
    def execute(self, name):
        return f"{name} is sleeping on a cat tree."

class CatSoundBehavior(SoundBehavior):
    def execute(self, name):
        return f"{name} says: Meow!"

class SnakeEatBehavior(EatBehavior):
    def execute(self, name):
        return f"{name} is eating mouse."

class SnakeSleepBehavior(SleepBehavior):
    def execute(self, name):
        return f"{name} is sleeping in a cozy corner."

class SnakeSoundBehavior(SoundBehavior):
    def execute(self, name):
        return f"{name} says: Hiss!"

# Animal class using Strategy pattern and inheritance
class Animal:
    def __init__(self, name, eat_behavior, sleep_behavior, sound_behavior):
        self.name = name
        self.eat_behavior = eat_behavior
        self.sleep_behavior = sleep_behavior
        self.sound_behavior = sound_behavior

    def eat(self):
        return self.eat_behavior.execute(self.name)

    def sleep(self):
        return self.sleep_behavior.execute(self.name)

    def make_sound(self):
        return self.sound_behavior.execute(self.name)

# Creating instances of animals with different behaviors
dog = Animal("Buddy", DogEatBehavior(), DogSleepBehavior(), DogSoundBehavior())
cat = Animal("Whiskers", CatEatBehavior(), CatSleepBehavior(), CatSoundBehavior())
snake = Animal("Slinky", SnakeEatBehavior(), SnakeSleepBehavior(), SnakeSoundBehavior())

# Performing actions
print(dog.eat())        # Output: "Buddy is eating dog food."
print(cat.sleep())      # Output: "Whiskers is sleeping on a cat tree."
print(snake.make_sound())  # Output: "Slinky says: Hiss!"
```
