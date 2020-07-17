---
title: 外观模式
author: Star.Y.Zheng
comments: true
categories: Java 设计模式
abbrlink: f7de8aa8
date: 2020-07-17 21:16:19
tags:
---

外观模式(Facade)，为子系统中的一组接口提供统一的接口。此模式定义了一个高层接口，这个接口使子系统更易于使用。简而言之，外观模式提供了到复杂子系统的简化接口。
<!-- more -->

### 外观模式解析

![外观模式结构图](facade.png)

**角色介绍**

- Facade：外观类，知道哪些子系统负责处理请求，将客户的请求代理给适当的子系统。
- SubSystemOne/SubSystemTwo：子系统类，实现子系统的功能，处理 Facade 对象指派的任务。

**外观模式基本代码**

- Facade 类：外观类

```java
/**
 * Facade
 */
public class Facade {
    
    private SubSystemOne subSystemOne;
    
    private SubSystemTwo subSystemTwo;
    
    public Facade() {
        this.subSystemOne = new SubSystemOne();
        this.subSystemTwo = new SubSystemTwo();
    }

    public void operationA() {
      this.subSystemOne.operation1();
      this.subSystemTwo.operation2();
    }

    public void operationB() {
      this.subSystemTwo.operation2();
    }
}
```

- SubSystemOne 类：子系统一

```java
/**
 * SubSystemOne
 */
public class SubSystemOne {

    public void operation1() {
        System.out.println("operation1");
    }
}
```

- SubSystemTwo 类：子系统二

```java
/**
 * SubSystemTwo
 */
public class SubSystemTwo {

    public void operation2() {
        System.out.println("operation2");
    }
}
```

### 示列

假设我们有一个带有一组接口的应用程序，以使用 MySQL / SQLServer 数据库并生成不同类型的报告，比如 HTML 报告，PDF 报告等。

因此，我们将使用不同的接口集来处理不同类型的数据库。 然后，客户端应用程序可以使用这些接口来获取所需的数据库连接并生成报告。

**使用外观设计模式实现**

首先，创建两个帮助程序接口，分别是 MySQLHelper 和 SQLServerHelper。
```java
/**
 * MySQLHelper
 */
public class MySQLHelper {
	
	public static Connection getMySQLDBConnection(){
		// 获取 MySQL 数据库连接对象
		return null;
	}
	
	public void generateMySQLPDFReport(String tableName, Connection con){
		// 从数据库中获取数据并生成 PDF 报告
	}
	
	public void generateMySqlHTMLReport(String tableName, Connection con){
		// 从数据库中获取数据并生成 HTML 报告
	}
}

/**
 * SQLServerHelper
 */
public class SQLServerHelper {

	public static Connection getSQLServerDBConnection(){
		// 获取 SQLServer 数据库连接对象
		return null;
	}
	
	public void generateSQLServerPDFReport(String tableName, Connection con){
		// 从数据库中获取数据并生成 PDF 报告
	}
	
	public void generateSQLServerHTMLReport(String tableName, Connection con){
		// 从数据库中获取数据并生成 HTML 报告
	}
	
}
```

然后，创建 Facade 类，为 MySQLHelper 和 SQLServerHelper 提供统一的界面。

```java
/**
 * HelperFacade
 */
public class HelperFacade {

	public static void generateReport(DBTypes dbType, ReportTypes reportType, String tableName){
		Connection con = null;
		switch (dbType){
		case MYSQL: 
			con = MySQLHelper.getMySQLDBConnection();
			MySQLHelper mySqlHelper = new MySQLHelper();
			switch(reportType){
			case HTML:
				mySqlHelper.generateMySQLHTMLReport(tableName, con);
				break;
			case PDF:
				mySqlHelper.generateMySQLPDFReport(tableName, con);
				break;
			}
			break;
		case ORACLE: 
			con = SQLServerHelper.getOracleDBConnection();
			SQLServerHelper sqlServerHelper = new SQLServerHelper();
			switch(reportType){
			case HTML:
				sqlServerHelper.generateSQLServerHTMLReport(tableName, con);
				break;
			case PDF:
				sqlServerHelper.generateSQLServerPDFReport(tableName, con);
				break;
			}
			break;
		}
		
	}
	
	public static enum DBTypes{
  MYSQL, SQLSERVER;
	}
	
	public static enum ReportTypes{
		HTML, PDF;
	}
} 
```

最后，创建客户端程序，分别使用 Facade 模式和不使用 Facade 模式生成报告。

```java
public class Client {

	public static void main(String[] args) {
		String tableName = "Student";
		
		// 不使用 Facade 模式生成报告
		Connection con = MySqlHelper.getMySqlDBConnection();
		MySqlHelper mySqlHelper = new MySqlHelper();
		mySqlHelper.generateMySqlHTMLReport(tableName, con);
		
		Connection con1 = OracleHelper.getOracleDBConnection();
		OracleHelper oracleHelper = new OracleHelper();
		oracleHelper.generateOraclePDFReport(tableName, con1);
		
		// 使用 Facade 模式生成报告
		HelperFacade.generateReport(HelperFacade.DBTypes.MYSQL, HelperFacade.ReportTypes.HTML, tableName);
		HelperFacade.generateReport(HelperFacade.DBTypes.ORACLE, HelperFacade.ReportTypes.PDF, tableName);
	}
}
```
从程序中可知，使用 Facade 模式界面是一种避免客户端逻辑过多的简便方法。获得数据库连接的 JDBC Driver Manager 类是外观设计模式的一个很好的例子。

我们还可以将工厂模式与外观模式结合使用，改善上面的代码，使程序更加易用。

### 小结

外观设计模式更像是客户端应用程序的助手，它不会对客户端隐藏子系统接口，是否使用Facade 完全取决于客户端代码。   

当客户端与抽象的实现类之间存在许多依赖关系，可以引入外观模式让子系统与客户端和其他子系统分离，从而提高子系统的独立性和可移植性。  

外观设计模式应应用于相似类型的接口，其目的是提供一个单一的接口，而不是提供多个执行相似类型工作的接口。