@FunctionalInterface
interface ButtonFunction{ //設計來作為按鈕點擊事件的回調，當 Button 類別的 click() 方法檢測到按鈕被點擊時，它會調用 ButtonFunction 介面提供的 function() 方法，從而觸發指定的操作
    void function();
}
