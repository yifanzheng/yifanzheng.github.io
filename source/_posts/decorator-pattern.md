---
title: 装饰者模式
author: Star.Y.Zheng
comments: true
categories: Java 设计模式
abbrlink: a708a60d
date: 2020-07-17 21:10:13
tags:
---

装饰者模式(Decorator)，动态地给一个对象添加一些额外的功能，就增加功能来说，装饰者模式比继承更灵活。

<!-- more -->

### 装饰者模式解析

![装饰者模式结构图](decorator-struct.png)

**角色介绍**

- Component：定义一个对象接口，可以给这些对象动态地添加功能。

- ConcreteComponent：是定义了一个具体的对象，也可以给这个对象添加一些功能。

- Decorator：装饰抽象类，继承了 Component，从外类来扩展 Component 类的功能，但对于 Component 来说，是无需知道 Decorator 的存在的.

- ConcreteDecorator(A/B)：具体的装饰对象，起到给 Component 添加功能的作用。

**装饰者模式基本代码**

- Component 类

```java
/**
 * Component
 */
public interface Component {

    void operation();
}
```

- ConcreteComponent 类

```java
/**
 * @author star
 */
public class ConcreteComponent implements Component {

    @Override
    public void operation() {
        System.out.println("具体的操作");
    }
}
```

- Decorator 类

```java
/**
 * Decorator
 */
public abstract class Decorator implements Component {

    protected Component component;

    public Decorator(Component component) {
        this.component = component;
    }

    @Override
    public void operation() {
        if (this.component == null) {
            return;
        }
        // 执行功能
        this.component.operation();
    }
}
```

- ConcreteDecoratorA 类

```java
/**
 * ConcreteDecoratorA
 */
public class ConcreteDecoratorA extends Decorator {

    public ConcreteDecoratorA(Component component) {
        super(component);
    }

    @Override
    public void operation() {
        // 执行原 Component 对象的功能
        super.operation();
        // 执行本类的功能
        System.out.println("装饰者 A 的操作");
    }
}
```

- ConcreteDecoratorB 类

```java
/**
 * ConcreteDecoratorB
 */
public class ConcreteDecoratorB extends Decorator {

    public ConcreteDecoratorB(Component component) {
        super(component);
    }

    @Override
    public void operation() {
        // 执行原 Component 对象的功能
        super.operation();
        // 执行本类的功能
        System.out.println("装饰者 B 的操作");
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
        // 装饰组件
        ConcreteDecoratorB decoratorB = new ConcreteDecoratorB(new ConcreteDecoratorA(new ConcreteComponent()));

        decoratorB.operation();
    }
}
```

### 示例

咖啡订单程序，咖啡种类有美式咖啡（American coffee）、无因咖啡（Causeless coffee），配料有牛奶（Milk），巧克力（Chocolate）。客户在点咖啡时可以选择配料进行混合。使用装饰者模式编程代码。

**类结构图**

![装饰者模式类结构图](decorator-code-struct.png)


**编码**

- Drink 类

```java
/**
 * Drink
 */
public abstract class Drink {

    protected String name;

    protected float price;

    public abstract float getCost();

    public abstract String getDescription();

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public float getPrice() {
        return price;
    }

    public void setPrice(float price) {
        this.price = price;
    }
}
```

- Cafe 类

```java
/**
 * Cafe
 */
public class Cafe extends Drink {

    @Override
    public float getCost() {
        return this.price;
    }

    @Override
    public String getDescription() {
        return "商品：" + this.name + "价格：" + this.price;
    }

}
```
- AmericanCafe 类

```java
/**
 * AmericanCafe
 */
public class AmericanCafe extends Cafe {

    public AmericanCafe() {
        this.name = "美式咖啡";
        this.price = 6.0f;
    }

}
```

- CauselessCafe 类

```java
/**
 * CauselessCafe
 */
public class CauselessCafe extends Cafe {

    public CauselessCafe() {
        this.name = "无因咖啡";
        this.price = 7.0f;
    }
}
```

- AbstractIngredients 类

```java
/**
 * AbstractIngredients
 */
public class AbstractIngredients extends Drink {

    private Drink drink;

    public AbstractIngredients(Drink drink) {
        this.drink = drink;
    }

    @Override
    public float getCost() {
        return super.price + this.drink.getCost();
    }

    @Override
    public String getDescription() {
        return drink.getDescription() + "配料：" + this.name + " 价格：" + this.price ;
    }
}
```

- Milk 类

```java
/**
 * Milk
 */
public class Milk extends AbstractIngredients {

    public Milk(Drink drink) {
        super(drink);
        this.name = "牛奶";
        this.price = 3.0f;
    }
}
```
- Chocolate 类

```java
/**
 * @author star
 */
public class Chocolate extends AbstractIngredients {

    public Chocolate(Drink drink) {
        super(drink);
        this.name = "巧克力";
        this.price = 2.0f;
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
        // 牛奶巧克力美式咖啡
        Drink drink = new Chocolate(new Milk(new AmericanCafe()));

        System.out.println(drink.getDescription());
        System.out.println(drink.getCost());
        
    }
}
```

### 小结

一般情况下，当系统需要新功能的时候，是向旧的类中添加新的代码。这些新加的代码通常装饰了原有类的核心职责或主要行为，但这种做法的问题在于，它们在主类中加入了新的字段，新的方法和新的逻辑，从而增加了主类的复杂度，而这些新加入的东西仅仅是为了满足一些只在某种特定情况下才执行的特殊行为的需要。  

而装饰者模式却提供了一个非常好的解决方案，装饰者模式是为已有功能动态地添加更多功能的一种方式，它把每个要装饰的功能放在单独的类中，并让这个类包装它所要装饰的对象，因此，当需要执行特殊行为时，客户代码就可以在运行时根据需要有选择地、按顺序地使用装饰功能包装对象了。  

装饰者模式的好处就是有效地把**类的核心职责**和**装饰功能**区分开了，而且可以去除相关类中重复的装饰逻辑。

