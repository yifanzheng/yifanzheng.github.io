---
title: 'Angular：使用[@Directive]自定义指令'
author: Star.Y.Zheng
comments: true
categories: Angular
abbrlink: eefcfb13
date: 2020-03-09 17:26:27
tags:
---

在 Angular 中有三种类型的指令：

- 组件，有模板的指令，组件是继承于指令的，只是扩展类与 UI 相关的属性。

- 属性型指令，改变 DOM 元素、组件或其他指令的行为和外观的指令。如，NgStyle、NgClass。

- 结构型指令，通过添加或移除 DOM 元素改变 DOM 布局的指令。如，NgIf、NgFor。

然而，在实际的开发中，根据业务的需要，我们经常会拓展 Angular 组件的指令来方便业务的开发。下面让我们来看看如何创建自己的指令。

<!-- more -->

### 创建属性型指令

在 Angular 中，属性型指令的创建至少需要一个带有 `@Directive` 装饰器的控制器类。这个装饰器指定了一个选择器名称，用于标识与指令相关联的属性名称。控制器类实现了指令的功能行为。

接下来，我们创建一个简单的指令，实现鼠标在元素上悬停时，改变起背景颜色；鼠标移开时，背景颜色消失；鼠标点击时，字体变大；鼠标松开时，字体恢复原样的功能。

**指令实现**

创建 background-exed.directive.ts 文件，实现如下代码：

```ts
import { Directive, HostListener, ElementRef, Renderer2, HostBinding } from '@angular/core';

@Directive({
  selector: '[appBackgroundExe]'
})
export class BackgroundExeDirective {

  @Input('appBackgroundExe')
  highLightColor: string;

  constructor(private elementRef: ElementRef, private renderer: Renderer2) {
    // 这种写法比较丑陋
    // this.elementRef.nativeElement.style.background = 'yellow';
    // 推荐这种写法， Renderer
    this.renderer.setStyle(this.elementRef.nativeElement, 'background', 'yellow');
  }

  @HostBinding('class.pressed')
  isPressed: boolean;

  @HostListener('mouseenter')
  onMouseEnter(): void {
   this.highLight(this.highLightColor);
  }

  @HostListener('mouseleave')
  onMouseLeave(): void {
    this.highLight(null);
  }

  @HostListener('mousedown')
  onMouseDown(): void {
    this.isPressed = true;
  }

  @HostListener('mouseup')
  onMouseUp(): void {
    this.isPressed = false;
  }

  private highLight(color: string): void {
    // this.elementRef.nativeElement.style.background = color;
    this.renderer.setStyle(this.elementRef.nativeElement, 'background', color);
  }

}
```
其中，`selector: '[appBackgroundExe]'` 是指令关联的属性名称，以便 Angular 在编译时，能从模板中找到与此指令关联的 HTML 代码。  

构造函数中，注入了 `ElementRef` 和 `Renderer2` 模块的实例。通过 `ElementRef` 我们可以引用指令标识的 DOM 元素，并对其进行相关的操作；并且可以利用 `Renderer2` 提供的 API 对元素进行相关的渲染操作。  

`@HostListener` 和 `@HostBinding` 是属性装饰器。`@HostListener` 是用来为宿主元素添加事件监听；而指令标记的元素，就是宿主元素。`@HostBinding` 是用来动态设置宿主元素的属性值。

**设置字体样式**

- appliation.component.less

```less
.pressed {
  font-size: 30px;
}
```

**在模板中使用指令**

- application.component.html

```html
<div class="panel panel-primary">
  <div [appBackgroundExe]="'red'">鼠标移进，元素变成红色。鼠标移出，元素红色消失</div>
</div>
```

### 创建结构型指令

结构型指令的创建与属性型指令创建大同小异。

**指令实现**

```ts
import { Directive, Input, TemplateRef, ViewContainerRef } from '@angular/core';

@Directive({
    selector: '[appIf]'
})
export class IfDirective {

    constructor(
        private templateRef: TemplateRef<any>,
        private viewContainerRef: ViewContainerRef
    ) { }

    @Input('ifCreat') 
    set condition(condition: boolean) {
       if (condition) {
         this.viewContainerRef.createEmbeddedView(this.templateRef);
       } else {
         this.viewContainerRef.clear();
       }
    }
}
```

其中，`TemplateRef` 表示内嵌的 template 模板元素，通过它可以创建内嵌视图。`ViewContainerRef` 表示一个视图容器，可以添加一个或多个视图，通过它可以创建和管理基于 `TemplateRef` 实例的内嵌视图或组件视图。

**在模板中使用指令**

- application.component.html

```html
<div class="panel panel-primary">
  <div *ifCreate="'true'">hello</div>
</div>
```

### 小结

本文主要介绍了在 Angular 中如何自定义创建指令。在实际的开发中，我们可以很灵活地创建我们想要的指令。
