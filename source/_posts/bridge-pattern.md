---
title: 桥接模式
author: Star.Y.Zheng
comments: true
categories: Java 设计模式
abbrlink: 563268dc
date: 2019-12-19 21:40:05
tags:
---

桥接模式（Bridge），将抽象部分和它的实现部分分离，使它们都可以独立地变化。  

桥接模式基于类的最小设计原则，通过使用封装、聚合及继承等行为让不同的类承担不同的职责。它的主要特点是把抽象与行为实现分离开来，从而可以保持各部分的独立性以及应对它们的功能扩展。

<!-- more -->

也就是说，实现系统可能有多种方式分类，每一种分类都有可能变化。桥接模式的核心意图就是把这些分类独立出来，让它们各自独立变化，减少它们之间的耦合。

### 桥接模式解析

![桥接模式结构图](bridge-struct.png)

**角色介绍**

- Abstraction：维护了 Implementor 类，两者是聚合关系，Abstraction 充当桥接类。
- RefinedAbstraction：是 Abstraction 抽象类的子类。
- Implementor：行为实现类的接口。
- ConcreteImplementorA/ConcreteImplementorA：行为的具体实现类。

**桥接模式基本代码**

- Abstraction 类

```java
public abstract class Abstraction {

    private Implementor implementor;

    public Abstraction(Implementor implementor) {
        this.implementor = implementor;
    }

    protected void operation() {
        implementor.operation();
    }
}
```

- RefinedAbstraction 类

```java
public class RefinedAbstraction extends Abstraction {

    public RefinedAbstraction(Implementor implementor) {
        super(implementor);
    }

    @Override
    protected void operation() {
        super.operation();
    }
}
```

- Implementor 类

```java
public interface Implementor {

    void operation();
}
```

- ConcreteImplementorA 类

```java
public class ConcreteImplementorA implements Implementor {

    @Override
    public void operation() {
        System.out.println("具体实现 A 的方法执行");
    }
}
```

- ConcreteImplementorB 类

```java
public class ConcreteImplementorB implements Implementor {

    @Override
    public void operation() {
        System.out.println("具体实现 B 的方法执行");
    }
}
```

- Main 类

```java
public class Main {

    public static void main(String[] args) {
        Implementor implementorA = new ConcreteImplementorA();
        Abstraction refinedAbstractionA = new RefinedAbstraction(implementorA);
        refinedAbstractionA.operation();

        Implementor implementorB = new ConcreteImplementorB();
        Abstraction refinedAbstractionB = new RefinedAbstraction(implementorB);
        refinedAbstractionB.operation();
    }
}
```

### 示例

手机操作问题，对不同品牌手机的不同软件功能进行编程，如通讯录、手机游戏等。

**传统方法**

- 结构图

![代码结构图](bridge-code-struct.png)

- 手机类

```java
/**
 * AbstractHandset
 */
public abstract class AbstractHandset {

    public abstract void run();
}
```

- 手机品牌 M 和手机品牌 N 类

```java
/**
 * HandsetM
 */
public abstract class HandsetM extends AbstractHandset {


}

/**
 * HandsetN
 */
public abstract class HandsetN extends AbstractHandset {
    
}
```

- 手机游戏类和手机 MP3 类

```java
/**
 * HandsetMGame
 */
public class HandsetMGame extends HandsetM {

    @Override
    public void run() {
        System.out.println("运行 M 品牌手机的游戏");
    }
}

/**
 * HandsetNGame
 */
public class HandsetNGame extends HandsetN {

    @Override
    public void run() {
        System.out.println("运行 N 品牌手机的游戏");
    }
}

/**
 * HandsetMMP3
 */
public class HandsetMMP3 extends HandsetM {

    @Override
    public void run() {
        System.out.println("运行 M 品牌手机的 MP3");
    }
}

/**
 * HandsetNMP3
 */
public class HandsetNMP3 extends HandsetN {

    @Override
    public void run() {
        System.out.println("运行 N 品牌手机的 MP3");
    }
}
```

- Main 类

```java
/**
 * Main
 */
public class Main {

    public static void main(String[] args) {
        HandsetM handsetM = new HandsetMGame();
        handsetM.run();

        HandsetN handsetN = new HandsetNMP3();
        handsetN.run();
    }
}
```

传统方法使用多层继承的方案，在扩展上存在**类爆炸**的问题。当我们要给每个品牌的手机增加一个新功能时，就要在每个品牌的手机下面增加一个子类，这样增加了代码维护的成本。

事实上，很多情况下使用继承会带来麻烦。对象的继承关系是在编译时就定义好了的，所以无法在运行时改变从父类继承的实现。子类的实现与它的父类有非常紧密的依赖关系，以至于父类实现中的任何变化必然导致其子类发生变化。当需要复用子类时，如果继承下来的实现不适合解决新的问题，则父类必须重写或被其他更适合的类替换。这种依赖关系限制了灵活性并最终限制复用。

**使用桥接模式改进**

- 结构图

![桥接结构图](bridge-code-struct1.png)

- 手机软件类

```java
/**
 * HandsetSoft
 */
public interface HandsetSoft {

    void run();
}
```
- 手机功能等具体类

```java
/**
 * HandsetGame
 */
public class HandsetGame implements HandsetSoft {

    @Override
    public void run() {
        System.out.println("运行手机游戏");
    }
}

/**
 * HandsetMP3
 */
public class HandsetMP3 implements HandsetSoft {

    @Override
    public void run() {
        System.out.println("运行手机 MP3");
    }
}
```

- 手机类

```java
/**
 * AbstractHandset
 */
public abstract class AbstractHandset {

    protected HandsetSoft handsetSoft;

    public AbstractHandset(HandsetSoft handsetSoft) {
        this.handsetSoft = handsetSoft;
    }

    public abstract void run();
}
```

- 手机具体品牌类

```java
/**
 * HandsetM
 */
public class HandsetM extends AbstractHandset {

    public HandsetM(HandsetSoft handsetSoft) {
        super(handsetSoft);
    }

    @Override
    public void run() {
        this.handsetSoft.run();
    }
}

/**
 * HandsetN
 */
public class HandsetN extends AbstractHandset {

    public HandsetN(HandsetSoft handsetSoft) {
        super(handsetSoft);
    }

    @Override
    public void run() {
        this.handsetSoft.run();
    }
}
```

- Main 类

```java
/**
 * Main
 */
public class Main {

    public static void main(String[] args) {
        HandsetM handsetM = new HandsetM(new HandsetGame());
        handsetM.run();

        HandsetN handsetN = new HandsetN(new HandsetMP3());
        handsetN.run();
    }
}
```

### 小结

桥接模式，实现了抽象和实现部分的分离，从而极大的提供了系统的灵活性，让抽象部分和实现部分独立开来，这有助于系统进行分层设计，从而产生更好的结构化系统。对于系统的高层部分，只需要知道抽象部分和实现部分的接口就可以了，其它的部分由具体业务来完成。**桥接模式替代多层继承方案，可以减少子类的个数，降低系统的管理和维护成本**。

桥接模式要求正确识别出系统中两个独立变化的维度(抽象和实现)，因此其使用范围有一定的局限性，即需要有这样的应用场景。
