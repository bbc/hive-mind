function startTime(label) {
    var today = new Date();
    var h = today.getHours();
    var m = today.getMinutes();
    var s = today.getSeconds();
    m = checkTime(m);
    s = checkTime(s);
    document.getElementById(label).innerHTML =
    h + ":" + m + ":" + s;
    var t = setTimeout(startTime, 500, label);
}

function checkTime(i) {
    if (i < 10) {i = "0" + i};
    return i;
}
