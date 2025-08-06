local lib = import '../lib/contact-points.libsonnet';

lib.createContactPoint(
    name='googlechat-using-grizzly',
    type='googlechat',
    settings={
        url: ' https://chat.googleapis.com/v1/spaces/AAQAInN8zho/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=KMLXlVtWSW1EZPu7D_kDd_IOdDxsfV9AWVTPw0XUcks'
    },
    orgId=1,
    disableResolveMessage=false
)