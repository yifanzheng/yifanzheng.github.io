---
title: 享元模式
author: Star.Y.Zheng
comments: true
categories: Java 设计模式
abbrlink: e19da94a
date: 2020-07-17 21:18:07
tags:
---
享元模式(Flyweight)，使用共享技术有效地支持大量细粒度的对象。常用于系统底层开发，解决系统的性能问题。比如，数据库连接池技术。

<!-- more -->

享元模式能够解决重复对象的内存浪费的问题，当系统中有大量相似对象，需要缓冲池时，不需总是创建新对象，可以从缓冲池里获取。这样可以降低系统内存消耗，同时提高效率。

享元模式经典的应用场景就是池技术了，String 常量池、数据库连接池、缓冲池等等都是享元模式的应用，它是池技术的重要实现方式。

要应用享元模式，我们需要将对象属性分为内部属性和外部属性。内部属性使对象唯一，而外部属性由客户端代码设置并用于执行不同的操作。

### 享元模式解析

![享元模式结构图](./asset/imgs/flyweight.png)

**角色介绍**

- Flyweight：它是所有具体享元类的超类或接口，通过这个接口，Flyweight 可以接受并作用于外部状态。

- ConcreteFlyweight：它是继承 Flyweight 超类或实现 Flyweight 接口，并为内部状态增加存储空间。

- UnsharedConcreteFlyweight：它是指那些不需要共享的Flyweight子类。因为 Flyweight 接口共享成为可能，但它并不强制共享。

- FlyweightFactory：它是一个享元工厂，用来创建并管理 Flyweight 对象.它主要是用来确保合理地共享 Flyweight ，当用户请求一个 Flyweight 时，Flywei ghtFactory 对象提供一个 已创建的实例或者创建一个（如果不存在的话）。

**享元模式基本代码**

- Flyweight 类

```java
public interface Flyweight {

    void operation(int status);
}
```

- ConcreteFlyweight 类

```java
public class ConcreteFlyweight implements Flyweight {

    @Override
    public void operation(int status) {
        System.out.println("具体的 Flyweight: " + status);
    }
}
```

- UnshareConcreteFlyweight 类

```java
public class UnshareConcreteFlyweight implements Flyweight {

    @Override
    public void operation(int status) {
        System.out.println("不共享的具体Flyweight: " + status);
    }
}
```

- FlyweightFactory 类

```java
public class FlyweightFactory {

    private static Map<String, Flyweight> flyweightMap = new HashMap<>();

    private FlyweightFactory() {

    }

    public static Flyweight getFlyweight(String key) {
        Flyweight flyweight = flyweightMap.get(key);
        if (flyweight == null) {
            if (Objects.equals(key, "A")) {
                flyweight = new ConcreteFlyweight();
            }

            if (Objects.equals(key, "B")) {
                flyweight = new ConcreteFlyweight();
            }
            flyweightMap.put(key, flyweight);
        }

        return flyweight;
    }

}
```

- Client 类

```java
public class Client {

    public static void main(String[] args) {
        // 外部状态
        int status = 2;
        Flyweight flyweightA = FlyweightFactory.getFlyweight("A");
        flyweightA.operation(status);

        Flyweight flyweightB = FlyweightFactory.getFlyweight("B");
        flyweightB.operation(status + 1);


        // 不共享的 Flyweight
        UnshareConcreteFlyweight unshareConcreteFlyweight = new UnshareConcreteFlyweight();
        unshareConcreteFlyweight.operation(status + 2);

    }
}
```

### 示例

假设我们需要使用线条和椭圆形创建图形。因此，我们将有一个接口 Shape 和它的具体实现为 Line 和 Oval。椭圆类将具有固有属性，以确定是否用给定的颜色填充椭圆，而 Line 将不具有任何固有属性。

**使用享元模式实现**

- Shape 类

```java
public interface Shape {

	public void draw(int x, int y, int width, int height, Color color);
}
```

- Line 类

```java
public class Line implements Shape {

	public Line(){
		System.out.println("Creating Line object");
	}

	@Override
	public void draw(int x1, int y1, int x2, int y2,
			Color color) {
			System.out.println("Draw Line");
	}

}
```

- Oval 类

```java
public class Oval implements Shape {
	
	// 内部属性
	private boolean fill;
	
	public Oval(boolean isFill){
		this.fill = fisFill;
		System.out.println("Creating Oval object");
	}
	@Override
	public void draw(int x, int y, int width, int height,
			Color color) {
		System.out.println("Draw Oval");
		if(fill){
			System.out.println("Fill Oval with color");
		}
	}
}
```

- ShapeFactory 类

```java
public class ShapeFactory {

	private static final Map<ShapeType,Shape> shapes = new HashMap<ShapeType,Shape>();

	public static Shape getShape(ShapeType type) {
		Shape shape = shapes.get(type);

		if (shape == null) {
			if (type.equals(ShapeType.OVAL_FILL)) {
				shape = new Oval(true);
			} else if (type.equals(ShapeType.OVAL_NOFILL)) {
				shape = new Oval(false);
			} else if (type.equals(ShapeType.LINE)) {
				shape = new Line();
			}
			shapes.put(type, shape);
		}
		return shape;
	}
	
	public static enum ShapeType{
		OVAL_FILL, OVAL_NOFILL, LINE;
	}
}
```

- Client 类

```java
public class Client {

  public static void main(String[] args) {
    Shape shape = ShapeFactory.getShape(ShapeType.LINE);
    // 伪代码
    shape.draw(x1, y1, x2, y2);

    Shape shape1 = ShapeFactory.getShape(ShapeType.LINE);
    // 伪代码
    shape1.draw(x1, y1, x2, y2);
  }
}
```

当我们多次创建 Line 图形时，由于程序使用了共享库，因此程序将快速执行。

### 小结

当我们需要创建一个类的许多对象且没有足够的内存容量时，可以使用享元模式。由于每个对象都会占用至关重要的内存空间，因此可以应用享元模式来通过共享对象来减少内存负载，同时也能提高程序效率。

事实上，享元模式可以避免大量非常相似类的开销。在程序设计中，有时需要生成大量细粒度的类实例来表示数据。如果能发现这些实例除了几个参数外基本上都是相同的，有时就能够受大幅度地减少需要实例化的类的数量。如果能把那些参数移到类实例的外面，在方法调用时将它们传递进来，就可以通过共享大幅度地减少单个实例的数目。

