---
title: 原型模式
author: Star.Y.Zheng
comments: true
abbrlink: 2756df06
date: 2019-12-09 22:56:15
categories: Java 设计模式
tags:
---

原型模式（Prototype），用原型实例指定创建对象的种类，并且通过拷贝这些原型，创建新的对象。  
原型模式是一种创建型设计模式，其实就是从一个对象再创建另外一个可定制的对象，而且不需要知道任何创建的细节。

<!-- more -->

**示例**

有一个简历类，必须要有姓名，可以设置性别和年龄，也可以设置工作经历。最后复制三份相同简历。

```java
/**
 * Resume
 */
public class Resume {

    private String name;

    private String sex;

    private String age;

    private String timeArea;

    private String company;

    public Resume(String name) {
        this.name = name;
    }

    public void setPersonInfo(String sex, String age) {
        this.sex = sex;
        this.age = age;
    }

    public void setWorkExperience(String timeArea, String company) {
        this.timeArea = timeArea;
        this.company = company;
    }

    @Override
    public String toString() {
        return "Resume{" +
                "name='" + name + '\'' +
                ", sex='" + sex + '\'' +
                ", age='" + age + '\'' +
                ", timeArea='" + timeArea + '\'' +
                ", company='" + company + '\'' +
                '}';
    }
}

/**
 * Main
 */
public class Main {

    public static void main(String[] args) {
        Resume a = new Resume("God.Gao");
        a.setPersonInfo("woman", "20");
        a.setWorkExperience("2014-2018", "XXXCompany");

        Resume b = new Resume("God.Gao");
        b.setPersonInfo("woman", "20");
        b.setWorkExperience("2014-2018", "XXXCompany");

        Resume c = new Resume("God.Gao");
        c.setPersonInfo("woman", "20");
        c.setWorkExperience("2014-2018", "XXXCompany");

        System.out.println(a.toString());
        System.out.println(b.toString());
        System.out.println(c.toString());
    }
}
```
此写法比较好理解，简单易操作。但是，假如需要二十份相同简历，就需要二十次实例化，并且每 new 一次，都需要执行一次构造函数，如果构造函数的执行时间很长，那么多次的执行这个初始化操作就实在是太低效了。假如我们又需要修改其中一个属性的值，那就要修改二十次，这样就很麻烦，效率也低。

**使用原型模式改进**

Java 中 Object 类是所有类的基类，Object 类提供了一个 clone() 方法，该方法可以将一个 Java 对象复制一份，但是需要实现 clone() 的 Java 类必须要实现一个 Cloneable 接口，这样就可以完成原型模式了。

```java
/**
 * Resume
 */
public class Resume implements Cloneable {

    private String name;

    private String sex;

    private String age;

    private String timeArea;

    private String company;

    public Resume(String name) {
        this.name = name;
    }

    public void setPersonInfo(String sex, String age) {
        this.sex = sex;
        this.age = age;
    }

    public void setWorkExperience(String timeArea, String company) {
        this.timeArea = timeArea;
        this.company = company;
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    @Override
    public String toString() {
        return "Resume{" +
                "name='" + name + '\'' +
                ", sex='" + sex + '\'' +
                ", age='" + age + '\'' +
                ", timeArea='" + timeArea + '\'' +
                ", company='" + company + '\'' +
                '}';
    }
}

/**
 * Main
 */
public class Main {

    public static void main(String[] args) throws CloneNotSupportedException {
        Resume a = new Resume("God.Gao");
        a.setPersonInfo("woman", "20");
        a.setWorkExperience("2014-2018", "XXXCompany");

        Resume b = (Resume) a.clone();

        Resume c = (Resume) a.clone();

        System.out.println(a.toString());
        System.out.println(b.toString());
        System.out.println(c.toString());
    }
}

```
原型模式实际就是对象的克隆。一般在初始化的信息不发生变化的情况下，克隆是最好的办法。这既隐藏了对象创建的细节，又对性能是大大的提高。

上述代码实现的克隆属于浅克隆。既然有浅克隆，就有深克隆。

### 浅克隆 VS 深克隆

**浅克隆**  

> 浅克隆是指，被复制对象的所有变量都含有与原来的对象相同的值，而所有的对其他对象的引用都仍然指向原来的对象。——《大话设计模式》

对于数据类型是基本数据类型的成员变量，浅克隆会直接进行值传递，也就是将该属性值复制一份给新的对象。  
对于数据类型是引用数据类型的成员变量，比如说成员变量是某个数组、某个类的对象等，那么浅克隆会进行引用传递，也就是只是将该成员变量的引用值(内存地址)复制一份给新的对象；因此原始对象及其复本引用同一对象。在这种情况下，在一个对象中修改该成员变量的值会影响到另一个对象的该成员变量的值。

**深克隆**   

深克隆，顾名思义，除了复制对象的所有基本数据类型的成员变量值，还为所有引用数据类型的成员变量申请存储空间，并复制每个引用数据类型成员变量所引用的对象，直到该对象可达的所有对象。也就是说，对象进行深克隆要对整个对象(包括对象的引用类型)进行复制。这样就不会出现一个对象的成员变量的值被修改会影响另一个对象的成员变量的值。

**浅克隆&深克隆示例对比**  

示例：复制下面的简历（Resume）类。

```java
public class Resume {

    private String name;

    private String sex;

    private String age;

    private WorkExperience workExperience;

    public Resume(String name) {
        this.name = name;
        this.workExperience = new WorkExperience();
    }

    public void setPersonInfo(String sex, String age) {
        this.sex = sex;
        this.age = age;
    }

    public void setWorkExperience(String workDate, String company) {
       this.workExperience.setWorkDate(workDate);
       this.workExperience.setCompany(company);
    }

    @Override
    public String toString() {
        return "Resume{" +
                "name='" + name + '\'' +
                ", sex='" + sex + '\'' +
                ", age='" + age + '\'' +
                ", workExperience=" + workExperience +
                '}';
    }
}

/**
 * WorkExperience
 */
public class WorkExperience {

    private String workDate;

    private String company;

    public String getWorkDate() {
        return workDate;
    }

    public void setWorkDate(String workDate) {
        this.workDate = workDate;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    @Override
    public String toString() {
        return "WorkExperience{" +
                "workDate='" + workDate + '\'' +
                ", company='" + company + '\'' +
                '}';
    }
}
```
- 使用浅克隆复制

```java
/**
 * Resume
 */
public class Resume implements Cloneable {

    private String name;

    private String sex;

    private String age;

    private WorkExperience workExperience;

    public Resume(String name) {
        this.name = name;
        this.workExperience = new WorkExperience();
    }

    public void setPersonInfo(String sex, String age) {
        this.sex = sex;
        this.age = age;
    }

    public void setWorkExperience(String workDate, String company) {
       this.workExperience.setWorkDate(workDate);
       this.workExperience.setCompany(company);
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    @Override
    public String toString() {
        return "Resume{" +
                "name='" + name + '\'' +
                ", sex='" + sex + '\'' +
                ", age='" + age + '\'' +
                ", workExperience=" + workExperience +
                '}';
    }
}

/**
 * WorkExperience
 */
public class WorkExperience implements Cloneable {

    private String workDate;

    private String company;

    public String getWorkDate() {
        return workDate;
    }

    public void setWorkDate(String workDate) {
        this.workDate = workDate;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    @Override
    public String toString() {
        return "WorkExperience{" +
                "workDate='" + workDate + '\'' +
                ", company='" + company + '\'' +
                '}';
    }
}

/**
 * Main
 */
public class Main {

    public static void main(String[] args) throws CloneNotSupportedException {
        Resume a = new Resume("God.Gao");
        a.setPersonInfo("woman", "20");
        a.setWorkExperience("2014-2018", "XXXCompany");

        Resume b = (Resume) a.clone();
        b.setWorkExperience("2015-2019", "xiaokejiCompany");

        Resume c = (Resume) a.clone();
        c.setWorkExperience("2014-2017", "yunCompany");

        System.out.println(a.toString());
        System.out.println(b.toString());
        System.out.println(c.toString());
    }
}
```

结果：

```java
Resume{name='God.Gao', sex='woman', age='20', workExperience=WorkExperience{workDate='2014-2017', company='yunCompany'}}
Resume{name='God.Gao', sex='woman', age='20', workExperience=WorkExperience{workDate='2014-2017', company='yunCompany'}}
Resume{name='God.Gao', sex='woman', age='20', workExperience=WorkExperience{workDate='2014-2017', company='yunCompany'}}
```
从结果可以看出，使用浅克隆复制对象，当对象中存在引用类型的成员变量时，只是复制了该成员变量的引用地址，并没有让该成员变量指向复制过的新对象。因此造成了一个对象修改该成员变量的值影响到了其他对象的该成员变量的值。

- 使用深克隆复制

深克隆有两种实现方式：1. 重写 clone() 方法，2. 使用序列化的方式。  

1. 重写 clone() 方法

```java
/**
 * Resume
 */
public class Resume implements Cloneable {

    private String name;

    private String sex;

    private String age;

    private WorkExperience workExperience;

    public Resume(String name) {
        this.name = name;
        this.workExperience = new WorkExperience();
    }

    public void setPersonInfo(String sex, String age) {
        this.sex = sex;
        this.age = age;
    }

    public void setWorkExperience(String workDate, String company) {
       this.workExperience.setWorkDate(workDate);
       this.workExperience.setCompany(company);
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        Resume resume = (Resume) super.clone();
        // 对引用类型的属性进行克隆
        resume.workExperience = (WorkExperience) this.workExperience.clone();
        return resume;
    }

    @Override
    public String toString() {
        return "Resume{" +
                "name='" + name + '\'' +
                ", sex='" + sex + '\'' +
                ", age='" + age + '\'' +
                ", workExperience=" + workExperience +
                '}';
    }
}


/**
 * WorkExperience
 */
public class WorkExperience implements Cloneable {

    private String workDate;

    private String company;

    public String getWorkDate() {
        return workDate;
    }

    public void setWorkDate(String workDate) {
        this.workDate = workDate;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    @Override
    public String toString() {
        return "WorkExperience{" +
                "workDate='" + workDate + '\'' +
                ", company='" + company + '\'' +
                '}';
    }
}

/**
 * Main
 */
public class Main {

    public static void main(String[] args) throws CloneNotSupportedException {
        Resume a = new Resume("God.Gao");
        a.setPersonInfo("woman", "20");
        a.setWorkExperience("2014-2018", "XXXCompany");

        Resume b = (Resume) a.clone();
        b.setWorkExperience("2015-2019", "xiaokejiCompany");

        Resume c = (Resume) a.clone();
        c.setWorkExperience("2014-2017", "yunCompany");

        System.out.println(a.toString());
        System.out.println(b.toString());
        System.out.println(c.toString());
    }
}
```

2. 使用序列化的方式

**注意**：使用序列化方式实现深克隆时，所涉及的类必须实现 Serializable 接口。

```java
/**
 * Resume
 */
public class Resume implements Serializable {

    private static final long serialVersionUID = 6395782880219068537L;

    private String name;

    private String sex;

    private String age;

    private WorkExperience workExperience;

    public Resume(String name) {
        this.name = name;
        this.workExperience = new WorkExperience();
    }

    public void setPersonInfo(String sex, String age) {
        this.sex = sex;
        this.age = age;
    }

    public void setWorkExperience(String workDate, String company) {
        this.workExperience.setWorkDate(workDate);
        this.workExperience.setCompany(company);
    }

    public Object deepClone() {
        ByteArrayOutputStream byteArrayOutputStream = null;
        ObjectOutputStream objectOutputStream = null;
        ByteArrayInputStream byteArrayInputStream = null;
        ObjectInputStream objectInputStream = null;

        try {
            // 创建对象输出流
            byteArrayOutputStream = new ByteArrayOutputStream();
            objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
            // 将对象以对象流的方式输出
            objectOutputStream.writeObject(this);

            // 创建对象输入流
            byteArrayInputStream = new ByteArrayInputStream(byteArrayOutputStream.toByteArray());
            objectInputStream = new ObjectInputStream(byteArrayInputStream);
            // 读取对象流
            return objectInputStream.readObject();
        } catch (IOException | SecurityException | ClassNotFoundException e) {
            return null;
        } finally {
            try {
                if (objectInputStream != null) {
                    objectInputStream.close();
                }
                if (byteArrayInputStream != null) {
                    byteArrayInputStream.close();
                }
                if (objectOutputStream != null) {
                    objectOutputStream.close();
                }
                if (byteArrayOutputStream != null) {
                    byteArrayOutputStream.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public String toString() {
        return "Resume{" +
                "name='" + name + '\'' +
                ", sex='" + sex + '\'' +
                ", age='" + age + '\'' +
                ", workExperience=" + workExperience +
                '}';
    }
}

/**
 * WorkExperience
 */
public class WorkExperience implements Serializable {

    private static final long serialVersionUID = -939371138425810409L;

    private String workDate;

    private String company;

    public String getWorkDate() {
        return workDate;
    }

    public void setWorkDate(String workDate) {
        this.workDate = workDate;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    @Override
    public String toString() {
        return "WorkExperience{" +
                "workDate='" + workDate + '\'' +
                ", company='" + company + '\'' +
                '}';
    }
}


/**
 * Main
 */
public class Main {

    public static void main(String[] args) {
        Resume a = new Resume("God.Gao");
        a.setPersonInfo("woman", "20");
        a.setWorkExperience("2014-2018", "XXXCompany");

        Resume b = (Resume) a.deepClone();
        b.setWorkExperience("2015-2019", "xiaokejiCompany");

        Resume c = (Resume) a.deepClone();
        c.setWorkExperience("2014-2017", "yunCompany");

        System.out.println(a.toString());
        System.out.println(b.toString());
        System.out.println(c.toString());
    }
}
```

结果：  

```java
Resume{name='God.Gao', sex='woman', age='20', workExperience=WorkExperience{workDate='2014-2018', company='XXXCompany'}}
Resume{name='God.Gao', sex='woman', age='20', workExperience=WorkExperience{workDate='2015-2019', company='xiaokejiCompany'}}
Resume{name='God.Gao', sex='woman', age='20', workExperience=WorkExperience{workDate='2014-2017', company='yunCompany'}}
```

### 小结

在创建新的对象比较复杂时，可以利用原型模式简化对象的创建过程，同时也能够提高效率，不用重新初始化对象，而是动态地获得对象运行时的状态。如果原始对象发生变化(增加或者减少属性)，其它克隆对象的也会发生相应的变化，无需修改代码。  
在实现深克隆的时候可能需要比较复杂的代码，需要为每一个类实现一个克隆方法，这对全新的类来说不是很难，但对已有的类进行改造时，需要修改其源代码，违背了开放封闭原则。












