@extends('layouts.admin')

@section('title')
    Locations &rarr; View &rarr; {{ $location->short }}
@endsection

@section('content-header')
    <h1>{{ $location->short }}<small>{{ str_limit($location->long, 75) }}</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.locations') }}">Locations</a></li>
        <li class="active">{{ $location->short }}</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-sm-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Location Details</h3>
            </div>
            <div class="box-body">
                <div class="form-group">
                    <label class="form-label">Short Code</label>
                    <input type="text" class="form-control" value="{{ $location->short }}" readonly disabled />
                </div>
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea class="form-control" rows="4" readonly disabled>{{ $location->long }}</textarea>
                </div>
                <p class="text-muted small" style="margin-bottom:0">Auto-managed location. Nodes connect automatically.</p>
            </div>
        </div>
    </div>
</div>
@endsection
