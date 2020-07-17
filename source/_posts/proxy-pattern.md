---
title: 代理模式
author: Star.Y.Zheng
comments: true
categories: Java 设计模式
abbrlink: 7b510e10
date: 2020-07-17 21:19:32
tags:
---

代理模式（Proxy）意图是为另一个对象提供代理，以控制对其的访问。即通过代理类访问目标类，这样做可以通过代理对象扩展目标类的功能以及控制对目标类的访问。

代理模式主要有三种形式，分别是**静态代理**、**动态代理**、**CGlib 代理**。

<!-- more -->

### 示例

假设，我们要记录老师授课前和授课后的信息，分别使用上面三种代理模式实现。

### 静态代理

若代理类在程序运行前就已经存在，那么这种代理方式被成为**静态代理** ，这种情况下的代理类通常都是我们在 Java 代码中定义的。使用静态代理实现时，需要定义接口或者父类，被代理类（即目标类）与代理类一起实现相同接口或者父类。

**代码示列**

- Teach 接口类

```java
/**
 * Teach
 */
public interface Teach {

    void doTeach();

}
```

- TeachImpl 类

```java
/**
 * TeachImpl
 */
public class TeachImpl implements Teach {

    @Override
    public void doTeach() {
        System.out.println("Do teach.");
    }
}
```

- TeachProxy 类

```java
/**
 * TeachProxy
 */
public class TeachProxy implements Teach {

    private Teach teach;

    public TeachProxy(Teach teach) {
        this.teach = teach;
    }

    @Override
    public void doTeach() {
        System.out.println("Do teach before.");
        this.teach.doTeach();
        System.out.println("Do teach after.");
    }
}
```

- Client 类

```java
/**
 * Client
 */
public class Client {

    public static void main(String[] args) {
        Teach teachProxy = new TeachProxy(new TeachImpl());
        teachProxy.doTeach();
    }
}
```

**静态代理特点**

在不改变目标类功能的前提下，能通过代理类对目标类进行功能扩展，同时可以实现客户端与目标类间的解耦。

但是，静态代理的局限在于运行前必须编写好代理对象，由于代理类和目标类都要实现相同的接口，所以会有很多代理类，一旦接口增加功能，目标类和代理类都需要进行维护，增加了维护负担。

### 动态代理

代理类在程序运行时创建的代理方式被成为**动态代理**，动态代理又叫 JDK 代理。这种情况下，代理类并不是在 Java 代码中定义的，而是在运行时根据我们在 Java 代码中的“指示”动态生成的。使用动态代理实现时，代理类不需要实现接口，目标类需要实现接口；代理对象的生成是利用 JDK 的 API(java.lang.reflect 包)，动态的在内存中创建对象。

JDK 实现动态代理，需要使用 `java.lang.reflect` 包下 Proxy 类中的方法：  
`public static Object newProxyInstance(ClassLoader loader, Class<?>[] interfaces, InvocationHandler h)`

方法参数介绍：  
`ClassLoader loader`: 指当前目标对象的类加载器。  
`Class<?>[] interfaces`: 目标对象实现的接口类型。  
`InvocationHandler h`: 处理程序，当执行目标对象的方法时，会触发处理程序，会把当前执行的目标对象的方法作为参数传入。


**代码示列**

- Teach 接口类

```java
/**
 * Teach
 */
public interface Teach {

    void doTeach();

}
```

- TeachImpl 类

```java
/**
 * TeachImpl
 */
public class TeachImpl implements Teach {

    @Override
    public void doTeach() {
        System.out.println("Do teach.");
    }
}
```

- TeachProxyFactory 类，用于动态创建代理

```java
/**
 * TeachProxyFactory
 */
public class TeachProxyFactory {

    private Object target;

    public TeachProxyFactory(Object target) {
        this.target = target;
    }

    public Object getInstance() {

        return Proxy.newProxyInstance(
                target.getClass().getClassLoader(),
                target.getClass().getInterfaces(),
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        System.out.println("Do teach before.");
                        Object invoke = method.invoke(target, args);
                        System.out.println("Do teach after.");
                        return invoke;
                    }
                }
        );
    }
}
```

- Client 类

```java
/**
 * Client
 */
public class Client {

    public static void main(String[] args) {
        Teach teachProxy = (Teach) new TeachProxyFactory(new TeachImpl()).getInstance();
        teachProxy.doTeach();
    }
}
```
**动态代理特点**

与静态代理相比，动态代理的优势在于可以很方便的对代理类的函数进行统一的处理，而不用修改每个代理类的函数。但是，动态代理的代理类字节码在创建时，需要实现目标类所实现的接口作为参数。如果目标类是没有实现接口而是直接定义业务方法的话，就无法使用 JDK 动态代理了。   

动态代理是基于接口实现的，只能对接口进行代理，不能对类进行代理。

### CGlib 代理

CGlib 代理模式是基于继承被代理类生成代理子类，不用实现接口。只需要被代理类是非 final 类即可。(CGlib 代理底层是借助 ASM 字节码技术）它也是一种动态代理。

**代码示列**

- Teach 接口类

```java
/**
 * Teach
 */
public interface Teach {

    void doTeach();

}
```

- TeachImpl 类

```java
/**
 * TeachImpl
 */
public class TeachImpl implements Teach {

    @Override
    public void doTeach() {
        System.out.println("Do teach.");
    }
}
```

- TeachMethodInterceptor 类

```java
/**
 * TeachMethodInterceptor
 */
public class TeachMethodInterceptor implements MethodInterceptor {

    private Class<?> target;

    public TeachMethodInterceptor(Class<?> target) {
        this.target = target;
    }

    public Object getProxyInstance() {
        // 为代理类指定需要代理的类，也即是父类
        Enhancer enhancer = new Enhancer();
        // 设置方法拦截器回调引用，对于代理类上所有方法的调用，
        // 都会调用 CallBack，而 Callback 则需要实现 intercept() 方法进行拦截
        enhancer.setSuperclass(target);
        // 获取动态代理类对象并返回
        enhancer.setCallback(this);
        return enhancer.create();
    }

    @Override
    public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
        System.out.println("Do Teach before.");
        Object result = proxy.invokeSuper(obj, args);
        System.out.println("Do Teach after.");
        return result;
    }
}
```

- Client 类

```java
/**
 * Client
 */
public class Client {

    public static void main(String[] args) {
        TeachMethodInterceptor methodInterceptor = new TeachMethodInterceptor(TeachImpl.class);
        Teach proxyInstance = (Teach) methodInterceptor.getProxyInstance();
        proxyInstance.doTeach();
    }
}
```

上述代码中，我们通过 CGlib 的 `Enhancer` 来指定要代理的目标对象，最终通过调用 `create()` 方法得到代理对象，对这个对象所有非 final 方法的调用都会转发给 `MethodInterceptor.intercept()` 方法，在 `intercept()` 方法里我们可以加入任何逻辑，比如修改方法参数，加入日志功能、安全检查功能等；通过调用 `MethodProxy.invokeSuper()` 方法，我们将调用转发给原始对象，也就是示例中 `TeachIpml` 的具体方法。

**CGlib 代理特点**

使用 CGLiB 实现动态代理，CGLi b底层采用 ASM 字节码生成框架，使用字节码技术生成代理类，比使用 Java 反射效率要高。唯一需要注意的是，CGLib 不能对声明为 final 的方法进行代理， 因为 CGLib 原理是动态生成被代理类的子类，是基于继承实现的。

### 小结

代理模式适用的几种常见情况

- 远程代理为不同地址空间中的对象提供了本地代表。
- 虚拟代理，当对象的实例化成本很高时，将使用虚拟代理。在实现中，它决定何时需要创建对象以及何时可以重用它。
- 保护代理用于控制对原始对象的访问。当对象应具有不同的访问权限时，保护代理很有用。
