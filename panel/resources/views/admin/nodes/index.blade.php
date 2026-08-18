@extends('layouts.admin')

@section('title')
    Nodes
@endsection

@section('content-header')
    <h1>Nodes</h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Nodes</li>
    </ol>
@endsection

@section('content')
<style>
    .hypixel-node-page{color:#dce6ef}
    .hn-hero{display:flex;align-items:center;justify-content:space-between;gap:18px;background:#252e3b;border:1px solid #38495a;border-top:3px solid #3c8dbc;border-radius:5px;padding:20px 22px;margin-bottom:18px;box-shadow:0 4px 16px rgba(0,0,0,.16)}
    .hn-kicker{display:flex;align-items:center;gap:9px;color:#75bde6;font-size:11px;font-weight:700;letter-spacing:.09em;text-transform:uppercase}
    .hn-pulse{width:9px;height:9px;background:#21c77a;border-radius:50%;box-shadow:0 0 0 4px rgba(33,199,122,.13)}
    .hn-hero h2{margin:9px 0 5px;color:#f4f8fb;font-size:21px;font-weight:500}
    .hn-hero p{margin:0;color:#9eacba;font-size:12px}
    .hn-actions{display:flex;align-items:center;gap:8px;flex-shrink:0}
    .hn-btn{display:inline-flex;align-items:center;justify-content:center;min-height:34px;padding:0 13px;border:1px solid #4a6072;border-radius:4px;background:#314252;color:#dce8f1;text-decoration:none;font-size:12px;cursor:pointer}
    .hn-btn:hover{background:#3a5265;color:#fff;text-decoration:none}
    .hn-btn.primary{background:#3c8dbc;border-color:#3c8dbc;color:#fff}
    .hn-btn.primary:hover{background:#337ba7}
    .hn-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(330px,1fr));gap:16px}
    .hn-card{position:relative;overflow:hidden;background:#252e3b;border:1px solid #38495a;border-radius:5px;box-shadow:0 4px 16px rgba(0,0,0,.15)}
    .hn-card-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:17px 18px;border-bottom:1px solid #38495a}
    .hn-node-title{display:flex;align-items:center;gap:12px;min-width:0}
    .hn-node-icon{width:38px;height:38px;display:grid;place-items:center;background:#203d52;border:1px solid #356985;border-radius:6px;color:#67b7e5;font-size:17px;flex-shrink:0}
    .hn-node-title h3{margin:0;color:#f0f5f8;font-size:16px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .hn-node-title p{margin:4px 0 0;color:#8fa1af;font-size:11px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .hn-status{display:inline-flex;align-items:center;gap:6px;padding:5px 8px;border:1px solid #35664e;border-radius:3px;background:#18392d;color:#72dda8;font-size:10px;font-weight:700;letter-spacing:.04em;white-space:nowrap}
    .hn-status.offline{border-color:#70424a;background:#41272d;color:#f19aa2}
    .hn-status.checking{border-color:#665b3a;background:#3a3422;color:#e6cb79}
    .hn-status-dot{width:7px;height:7px;background:currentColor;border-radius:50%}
    .hn-card-body{padding:17px 18px}
    .hn-auto{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:10px 11px;margin-bottom:15px;background:#202b36;border:1px solid #354858;border-radius:4px;color:#b6c5d0;font-size:11px}
    .hn-auto strong{display:block;color:#e5edf3;font-size:12px;margin-bottom:3px}
    .hn-auto span{color:#7eafc6;font-family:monospace;font-size:10px}
    .hn-check{color:#6fd69e;font-size:11px;white-space:nowrap}
    .hn-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}
    .hn-stat{min-width:0;padding:11px 10px;background:#202a35;border:1px solid #354554;border-radius:4px}
    .hn-stat-label{display:block;color:#8496a5;font-size:10px;text-transform:uppercase;letter-spacing:.04em;margin-bottom:6px}
    .hn-stat-value{display:block;color:#e9f0f5;font-size:13px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .hn-runtime{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:8px}
    .hn-runtime div{padding:8px 10px;border-top:1px solid #354554;color:#9aabb8;font-size:11px}
    .hn-runtime b{display:block;color:#dce6ed;font-weight:500;margin-top:3px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .hn-card-foot{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:12px 18px;border-top:1px solid #38495a;background:#222b35;color:#91a2af;font-size:11px}
    .hn-card-foot a{color:#70b9df;text-decoration:none}
    .hn-card-foot a:hover{color:#a8d9f2}
    .hn-last{font-size:10px;color:#728390}
    .hn-empty{padding:40px 20px;text-align:center;background:#252e3b;border:1px solid #38495a;border-radius:5px;color:#96a5b1}
    @media(max-width:650px){.hn-hero{display:block;padding:16px}.hn-actions{margin-top:14px}.hn-actions .hn-btn{flex:1}.hn-grid{grid-template-columns:1fr}.hn-card-head{padding:14px}.hn-card-body{padding:14px}.hn-card-foot{padding:11px 14px}.hn-stats{gap:6px}.hn-stat{padding:10px 8px}.hn-stat-value{font-size:12px}}
</style>

<div class="hypixel-node-page">

    <div class="hn-grid">
        @forelse ($nodes as $node)
            <article class="hn-card hn-node" data-node-id="{{ $node->id }}" data-status-url="{{ url('/admin/nodes/view/'.$node->id.'/system-information') }}">
                <div class="hn-card-head">
                    <div class="hn-node-title">
                        <div class="hn-node-icon"><i class="fa fa-server"></i></div>
                        <div>
                            <h3>{{ config('hypixel.public_ip') ?: $node->fqdn }}</h3>
                        </div>
                    </div>
                    <span class="hn-status checking" data-node-status><span class="hn-status-dot"></span><span data-status-text>CONNECTING</span></span>
                </div>
                <div class="hn-card-body">
                    <div class="hn-stats">
                        <div class="hn-stat"><span class="hn-stat-label">Memory</span><span class="hn-stat-value" data-memory-total>--</span></div>
                        <div class="hn-stat"><span class="hn-stat-label">Disk</span><span class="hn-stat-value" data-disk-total>--</span></div>
                        <div class="hn-stat"><span class="hn-stat-label">CPU Threads</span><span class="hn-stat-value" data-cpu-threads>--</span></div>
                    </div>
                    <div class="hn-runtime">
                        <div>Hostname<b data-hostname>Detecting...</b></div>
                        <div>OS / Kernel<b data-system>Detecting...</b></div>
                        <div>CPU threads<b data-cpu>Detecting...</b></div>
                        <div>CPU model<b data-cpu-model>Detecting...</b></div>
                        <div>RAM actual<b data-memory>Detecting...</b></div>
                        <div>SSD / Disk<b data-disk>Detecting...</b></div>
                        <div>Uptime<b data-uptime>Detecting...</b></div>
                        <div>Daemon<b data-version>Detecting...</b></div>
                    </div>
                </div>
                <div class="hn-card-foot">
                    <span class="hn-last" data-last>Waiting for status</span>
                    <a href="{{ route('admin.nodes.view.allocation', $node->id) }}">Manage node <i class="fa fa-angle-right"></i></a>
                </div>
            </article>
        @empty
            <div class="hn-empty">No auto-connected VPS nodes available.</div>
        @endforelse
    </div>
</div>
@endsection

@section('footer-scripts')
    @parent
    <script>
    function bytes(n) {
        n = Number(n || 0);
        var units = ['B','KiB','MiB','GiB','TiB'];
        var i = 0;
        while (n >= 1024 && i < units.length - 1) { n /= 1024; i++; }
        return (i === 0 ? Math.round(n) : n.toFixed(1)) + ' ' + units[i];
    }
    function duration(sec) {
        sec = Math.max(0, Number(sec || 0));
        var d = Math.floor(sec / 86400); sec %= 86400;
        var h = Math.floor(sec / 3600); sec %= 3600;
        var m = Math.floor(sec / 60);
        return (d ? d + 'd ' : '') + h + 'h ' + m + 'm';
    }
    function setNodeState(card, online, data, error) {
        var status = card.querySelector('[data-node-status]');
        var text = card.querySelector('[data-status-text]');
        var last = card.querySelector('[data-last]');
        status.classList.remove('checking', 'offline');
        if (online) {
            text.textContent = 'ONLINE';
            var si = data.system || {}, mem = si.memory || {}, disk = si.disk || {};
            card.querySelector('[data-hostname]').textContent = si.hostname || '--';
            card.querySelector('[data-system]').textContent = (si.type || 'Linux') + ' ' + (si.arch || '') + ' / ' + (si.release || '');
            var mhz = Number(si.cpu_speed_mhz || 0); var model = si.cpu_model || '--'; var match = model.match(/@\s*([0-9.]+)\s*GHz/i); var speed = mhz ? (mhz + ' MHz') : (match ? match[1] + ' GHz' : 'n/a'); card.querySelector('[data-cpu]').textContent = String(si.cpus || 0) + ' threads @ ' + speed;var ct=card.querySelector('[data-cpu-threads]');if(ct)ct.textContent=String(si.cpus||0)+' threads';
            card.querySelector('[data-cpu-model]').textContent = si.cpu_model || '--';
            card.querySelector('[data-memory]').textContent = bytes(mem.used) + ' used / ' + bytes(mem.total);
            card.querySelector('[data-disk]').textContent = (disk.type || 'Unknown') + ' · ' + bytes(disk.used) + ' / ' + bytes(disk.total);var mt=card.querySelector('[data-memory-total]');if(mt)mt.textContent=bytes(mem.total);var dt=card.querySelector('[data-disk-total]');if(dt)dt.textContent=bytes(disk.total);
            card.querySelector('[data-uptime]').textContent = duration(si.uptime);
            card.querySelector('[data-version]').textContent = data.version || 'Connected';
        } else {
            status.classList.add('offline');
            text.textContent = 'OFFLINE';
            card.querySelectorAll('[data-hostname],[data-system],[data-cpu],[data-cpu-model],[data-memory],[data-disk],[data-uptime],[data-version]').forEach(function(el){el.textContent='Unavailable'});
        }
        var lbl = 'Checked ' + new Date().toLocaleTimeString();
        last.textContent = lbl;
        card.dataset.lastTs = String(Date.now());
        card.dataset.lastLabel = lbl;
    }
    function pingHypixelNode(card) {
        $.ajax({method:'GET',url:card.dataset.statusUrl,timeout:8000,dataType:'json'})
            .done(function(data){setNodeState(card,true,data,null)})
            .fail(function(xhr){
                var msg = 'Connection failed';
                if (xhr.status === 401 || xhr.status === 403) msg = 'Auth rejected';
                setNodeState(card,false,null,msg);
            });
    }
    function refreshHypixelNodes() { $('.hn-node').each(function(){ pingHypixelNode(this); }); }
    function tickHypixelClocks(){
        $('.hn-node').each(function(){
            var last=this.querySelector('[data-last]');
            if(!last||!this.dataset.lastTs)return;
            var secs=Math.floor((Date.now()-Number(this.dataset.lastTs))/1000);
            var base=this.dataset.lastLabel||'';
            last.textContent=base+(secs>0?(' · '+secs+'s ago'):'');
        });
    }
    setInterval(tickHypixelClocks,1000);
    (function autoConnectHypixelNodes(){
        refreshHypixelNodes();
        setInterval(refreshHypixelNodes,1000);
    })();
    </script>
@endsection
