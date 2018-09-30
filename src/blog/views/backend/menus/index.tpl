<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>btable</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="format-detection" content="telephone=no">

    <link rel="stylesheet" href="/static/plugins/layui/css/layui.css" media="all" />
    <link rel="stylesheet" href="/static/plugins/font-awesome/css/font-awesome.min.css">
    <link rel="stylesheet" href="/static/css/btable.css" />
</head>
<body style=" background-color: gainsboro;">
<div style="margin:0px; background-color: white; margin:0 10px;">
    <blockquote class="layui-elem-quote">
        <button type="button" class="layui-btn layui-btn-small" id="Add"><i class="fa fa-plus" aria-hidden="true"></i> 添加</button>
        <form class="layui-form" style="float:right;">
            <input type="hidden" name="_xsrf" id="xsrf_token" value="<<< .xsrf_token >>>">
            <div class="layui-form-item" style="margin:0;">
                <label class="layui-form-label">类型:</label>
                <div class="layui-input-inline">
                    <select name="is_front" lay-filter="IsFront">
                        <option value="">全 部</option>
                        <option value="">全 部</option>
                        <option value="1">前台菜单</option>
                        <option value="2">后台菜单</option>
                    </select>
                </div>
                <label class="layui-form-label">名称:</label>
                <div class="layui-input-inline">
                    <input type="text" name="name" placeholder="支持模糊查询.." autocomplete="off" class="layui-input">
                </div>
                <div class="layui-form-mid layui-word-aux" style="padding:0;">
                    <button lay-filter="search" class="layui-btn" lay-submit><i class="fa fa-search" aria-hidden="true"></i> 查询</button>
                </div>
            </div>
        </form>
    </blockquote>
    <div id="content" style="width: 100%;height: auto;"></div>
</div>
<script type="text/javascript" src="/static/plugins/layui/layui.js"></script>
<script>
    layui.config({
        base: '/static/js/',
        v: new Date().getTime()
    }).use(['btable', 'form', 'baajax'], function () {
        var btable = layui.btable(),
            $ = layui.jquery,
            layerTips = parent.layer === undefined ? layui.layer : parent.layer, //获取父窗口的layer对象
            layer = layui.layer,//获取当前窗口的layer对象;
            form = layui.form(),
            baajax = layui.baajax;
        ;

        btable.set({
            openWait: true,//开启等待框
            elem: '#content',
            url: '/admin/menu', //数据源地址
            //pageSize: 10,//页大小
            params: {
                //t: new Date().getTime()
            },
            columns: [{ //配置数据列
                fieldName: '菜单名', //显示名称
                field: 'Name', //字段名
                sortable: true //是否显示排序
            }, {
                fieldName: '排序',
                field: 'Sort',
                sortable: true
            },{
                fieldName: ' 描述',
                field: 'Desc',
                sortable: false
            }, {
                fieldName: '路径',
                field: 'Url',
                sortable: false
            }, {
                fieldName: '图标',
                field: 'Icon',
                sortable: false
            },{
                fieldName: ' 顶级?',
                field: 'Pid',
                sortable: false
            },{
                fieldName: ' 菜单类型',
                field: 'IsFront',
                sortable: false
            },{
                fieldName: '创建时间',
                field: 'CreatedAt',
                sortable: true
            },{
                fieldName: '更新时间',
                field: 'UpdatedAt',
                sortable: true
            }, {
                fieldName: '操作',
                field: 'Id',
                format: function (val, obj) {
                    var html = '<input type="button" value="编辑" data-action="edit" data-id="' + val + '" class="layui-btn layui-btn-mini" /> ' +
                        '<input type="button" value="删除" data-action="del" data-id="' + val + '" class="layui-btn layui-btn-mini layui-btn-danger" />';
                    return html;
                }
            }],
            even: true,//隔行变色
            field: 'Id', //主键ID
            skin: 'row',
            checkbox: false,//是否显示多选框
            paged: true, //是否显示分页
            singleSelect: false, //只允许选择一行，checkbox为true生效
            onSuccess: function ($elem) { //$elem当前窗口的jq对象
                $elem.children('tr').each(function () {
                    $(this).children('td').each(function () {
                        var field = $(this).data("field");
                        if(field == 'IsFront') {
                            var field_value = $(this).html();
                            if(field_value == "1" ) {
                                $(this).html("前台菜单")
                            } else {
                                $(this).html("后台菜单")
                            }
                        }
                    });
                    $(this).children('td:last-child').children('input').each(function () {
                        var $that = $(this);
                        var action = $that.data('action');
                        var id = $that.data('id');
                        $that.on('click', function () {
                            switch (action) {
                                case 'edit':
                                    $.get('/admin/menu/edit_menu/'+id, null, function(form) {
                                        addBoxIndex = layer.open({
                                            type: 1,
                                            title: '编辑菜单',
                                            content: form,
                                            skin:"layui-layer-molv",
                                            btn: ['保存', '取消'],
                                            shade: false,
                                            offset: ['30px', '15%'],
                                            area: ['650px', '550px'],
                                            zIndex: 19950924,
                                            maxmin: true,
                                            yes: function(index) {
                                                //触发表单的提交事件
                                                $('form.layui-form').find('button[lay-filter=edit]').click();
                                            },
                                            full: function(elem) {
                                                var win = window.top === window.self ? window : parent.window;
                                                $(win).on('resize', function() {
                                                    var $this = $(this);
                                                    elem.width($this.width()).height($this.height()).css({
                                                        top: 0,
                                                        left: 0
                                                    });
                                                    elem.children('div.layui-layer-content').height($this.height() - 95);
                                                });
                                            },
                                            success: function(layero, index) {
                                                //弹出窗口成功后渲染表单
                                                var form = layui.form();
                                                form.render();
                                                form.on('submit(edit)', function(data) {
                                                    //调用父窗口的layer对象
                                                    baajax.post('/admin/menu/post_edit_menu', data.field, function(ret){
                                                        layerTips.msg(ret.msg);
                                                        layerTips.close(index);
                                                        location.reload(); //刷新
                                                    });
                                                    //这里可以写ajax方法提交表单
                                                    return false; //阻止表单跳转。如果需要表单跳转，去掉这段即可。
                                                });
                                                //console.log(layero, index);
                                            },
                                            end: function() {
                                                addBoxIndex = -1;
                                            }
                                        });
                                    });
                                    break;
                                case 'del': //删除
                                    var name = $that.parent('td').siblings('td[data-field=Name]').text();
                                    //询问框
                                    layerTips.confirm('确定要删除[ <span style="color:red;">' + name + '</span> ] ？', { icon: 3, title: '系统提示' }, function (index) {
                                        layerTips.close(index);
                                        baajax.post("/admin/menu/delete_select", {ids:id}, function(res){
                                            layerTips.close()
                                            layer.alert(res.msg);
                                            setTimeout(function () {
                                                location.reload();
                                            }, 1000)
                                        })
                                    });
                                    break;
                            }
                        });
                    });

                });
            }
        });
        btable.render();
        //监听搜索表单的提交事件
        form.on('submit(search)', function (data) {
            var search = '';
            $.each(data.field, function (k,v) {
                if (k != '_xsrf') {
                    search += k+"__contains:" + layui.common.trim(v)+','
                }
            });
            var query = [];
            query['query'] = search;
            btable.get(query);
            return false;
        });
        $(window).on('resize', function (e) {
            var $that = $(this);
            $('#content').height($that.height() - 92);
        }).resize();
        var addBoxIndex = -1;
        $("#Add").on("click", function () {
            if(addBoxIndex !== -1)
                return;
            $.get('/admin/menu/add_menu', null, function(form) {
                addBoxIndex = layer.open({
                    type: 1,
                    title: '添加菜单',
                    content: form,
                    skin:"layui-layer-molv",
                    btn: ['保存', '取消'],
                    shade: false,
                    offset: ['30px', '15%'],
                    area: ['650px', '550px'],
                    zIndex: 19950924,
                    maxmin: true,
                    yes: function(index) {
                        //触发表单的提交事件
                        $('form.layui-form').find('button[lay-filter=edit]').click();
                    },
                    full: function(elem) {
                        var win = window.top === window.self ? window : parent.window;
                        $(win).on('resize', function() {
                            var $this = $(this);
                            elem.width($this.width()).height($this.height()).css({
                                top: 0,
                                left: 0
                            });
                            elem.children('div.layui-layer-content').height($this.height() - 95);
                        });
                    },
                    success: function(layero, index) {
                        //弹出窗口成功后渲染表单
                        var form = layui.form();
                        form.render();
                        form.on('submit(edit)', function(data) {
                            //调用父窗口的layer对象
                            baajax.post('/admin/menu/post_add_menu', data.field, function(ret){
                                layerTips.msg(ret.msg);
                                layerTips.close(index);
                                location.reload(); //刷新
                            });
                            //这里可以写ajax方法提交表单
                            return false; //阻止表单跳转。如果需要表单跳转，去掉这段即可。
                        });
                        //console.log(layero, index);
                    },
                    end: function() {
                        addBoxIndex = -1;
                    }
                });
            });
        })
    });
</script>
</body>
</html>