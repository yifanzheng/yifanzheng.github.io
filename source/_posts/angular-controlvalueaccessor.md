---
title: 'Angular: [ControlValueAccessor] 自定义表单控件'
author: Star.Y.Zheng
comments: true
categories: Angular
abbrlink: 91c5f804
date: 2020-03-09 17:23:32
tags:
---

我们在实际开发中，通常会遇到各种各样的定制化功能，会遇到有些组件会与 Angular 的表单进行交互，这时候我们一般会从外部传入一个 FormGroup 对象，然后在组件的内部写相应的逻辑对 Angular 表单进行操作。如果我们只是对表单中的一个项进行定制，将整个表单对象传入显然不合适，并且组件也会显得臃肿。

<!-- more -->

```ts
<form [formGroup]="simpleForm">                                
  <other-component [form]="simpleForm"></other-component>        
</form>
```
那么，我们能不能像原生表单一样去使用这些自定义组件呢？目前，开源组件 ng-zorro-antd 表单组件能和原生表单一样使用 formControlName 这个属性，这类组件就叫自定义表单组件。

### 如何实现自定义表单控件

在 Angular 中，使用 ControlValueAccessor 可以实现组件与外层包裹的 form 关联起来。

ControlValueAccessor是用于处理以下内容的接口：
- 将表单模型中的值写入视图/ DOM
- 在视图/ DOM更改时通知其他表单指令和控件

**ControlValueAccessor**

ControlValueAccessor 接口定义了四个方法：

```java
writeValue(obj: any): void

registerOnChange(fn: any): void

registerOnTouched(fn: any): void

setDisabledState(isDisabled: boolean)?: void
```
`writeValue(obj：any)`：将表单模型中的新值写入视图或DOM属性（如果需要）的方法，它将来自外部的数据写入到内部的数据模型。数据流向： form model -> component。

`registerOnChange(fn：any)`：一种注册处理程序的方法，当视图中的某些内容发生更改时应调用该处理程序。它具有一个告诉其他表单指令和表单控件以更新其值的函数。通常在 registerOnChange 中需要保存该事件触发函数，在数据改变的时候，可以通过调用事件触发函数通知外部数据变了，同时可以将修改后的数据作为参数传递出去。数据流向： component -> form model。

`registerOnTouched(fn: any)`：注册 onTouched 事件，基本同 registerOnChange ，只是该函数用于通知表单组件已经处于 touched 状态，改变绑定的 FormControl 的内部状态。状态变更： component -> form model。

`setDisabledState(isDisabled: boolean)`：当调用 FormControl 变更状态的 API 时得表单状态变为 Disabled 时调用 setDisabledState() 方法，以通知自定义表单组件当前表单的读写状态。状态变更： form model -> component。

### 如何使用 ControlValueAccessor

**搭建控件框架**  

```ts
@Component({
  selector: 'app-test-control-value-accessor',
  templateUrl: './test-control-value-accessor.component.html',
  providers: [{
    provide: NG_VALUE_ACCESSOR,
    useExisting: forwardRef(() => TestControlValueAccessorComponent),
    multi: true
  }]
})
export class TestControlValueAccessorComponent implements ControlValueAccessor {

  _counterValue = 0;
 
  private onChange = (_: any) => {};

  constructor() { }

  get counterValue() {
    return this._counterValue;
  }

  set counterValue(value) {
    this._counterValue = value;
    // 触发 onChange，component 内部的值同步到 form model
    this.onChange(this._counterValue);
  }

  increment() {
    this.counterValue++;
  }

  decrement() {
    this.counterValue--;
  }

  // form model 的值同步到 component 内部
  writeValue(obj: any): void {
    if (obj !== undefined) {
      this.counterValue = obj;
    }
  }

  registerOnChange(fn: any): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: any): void { }

  setDisabledState?(isDisabled: boolean): void { }

}
```
**注册 ControlValueAccessor**

为了获得 `ControlValueAccessor` 用于表单控件，Angular 内部将注入在`NG_VALUE_ACCESSOR `令牌上注册的所有值，这是将控件本身注册到 `DI` 框架成为一个可以让表单访问其值的控件。因此，我们需要做的就是`NG_VALUE_ACCESSOR` 使用我们自己的值访问器实例（这是我们的组件）扩展 multi-provider 。所以设置 `multi: true`，是声明这个 `token` 对应的类很多，分散在各处。

这里我们必须使用 `useExisting`，因为`CounterInputComponent` 可能在使用它的组件中被其创建为指令依赖项。这就得用到 `forwardRef` 了，这个函数允许我们引用一个尚未定义的对象。

```ts
@Component({
  ...
  providers: [
    { 
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => TestControlValueAccessorComponent ),
      multi: true
    }
  ]
})
export class TestControlValueAccessorComponent implements ControlValueAccessor {
  ...
}
```

**控件界面**

- test-control-value-accessor.component.html

```html
<div class="panel panel-primary">
  <div class="panel-heading">自定义控件</div>
  <div class="panel-body">
    <button (click)="increment()">+</button>
    {{counterValue}}
    <button (click)="decrement()">-</button>
  </div>
</div>
```
**在表单中使用**   

- app.component.html

```html
<div class="constainer">
  <form #form="ngForm">
    <app-test-control-value-accessor name="message" [(ngModel)]="message"></app-test-control-value-accessor>
    <button type="button" (click)="submit(form.value)">Submit</button>
  </form>
  <pre>{{ message }}</pre>
</div>
```
- app.component.ts

```ts
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {

  message = 5;

  submit(value: any): void {
    console.log(value);
  }

}
```

### 参考
- [https://blog.thoughtram.io/angular/2016/07/27/custom-form-controls-in-angular-2.html](https://blog.thoughtram.io/angular/2016/07/27/custom-form-controls-in-angular-2.html)

- [https://almerosteyn.com/2016/04/linkup-custom-control-to-ngcontrol-ngmodel](https://almerosteyn.com/2016/04/linkup-custom-control-to-ngcontrol-ngmodel)  

- [https://juejin.im/post/597176886fb9a06ba4746d15](https://juejin.im/post/597176886fb9a06ba4746d15)

- [https://github.com/shhdgit/blogs/issues/11](https://github.com/shhdgit/blogs/issues/11)

