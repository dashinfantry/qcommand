#include "commandengine.h"

CommandEngine::CommandEngine() : QObject()
{
    process = nullptr;
}

void CommandEngine::exec(QString cmd, bool emitOutput)
{
    create(emitOutput);
    QStringList args;
    args << "-c" << cmd;
    process->start("bash", args, QProcess::ReadOnly);
    process->closeWriteChannel();
}

void CommandEngine::execAsRoot(QString cmd, bool emitOutput, QString password)
{
    create(emitOutput);
    QStringList args;
    args << "bash" << "-c" << cmd;
    process->start("devel-su", args);
    process->write((password + "\n").toUtf8().data());
    process->closeWriteChannel();
    process->waitForReadyRead(500);
    process->readAllStandardError();
}

void CommandEngine::create(bool emitOutput)
{
    if (process)
    {
        process->disconnect();
        QObject::connect(process, SIGNAL(finished(int)), this, SLOT(cleanup()));
        if (process->state() != QProcess::ProcessState::Running)
        {
            delete process;
        }
        process = nullptr;
    }
    process = new QProcess();
    process->setReadChannel(QProcess::ProcessChannel::StandardError);
    if (emitOutput)
    {
        QObject::connect(process, SIGNAL(finished(int)), this, SLOT(finished(int)));
    }
    else
    {
        QObject::connect(process, SIGNAL(finished(int)), this, SLOT(finishedErrorOnly(int)));
    }
}

void CommandEngine::finished(int status)
{
    if (!process)
    {
        return;
    }
    emit output(parse(process->readAllStandardOutput()));
    QString errors = process->readAllStandardError();
    if (status || errors != "")
    {
        emit errorState();
        emit error(parse(errors));
    }
}

void CommandEngine::finishedErrorOnly(int status)
{
    if (!process)
    {
        return;
    }
    QString errors = process->readAllStandardError();
    if (status || errors != "")
    {
        emit errorState();
    }
}

QStringList CommandEngine::parse(QString output)
{
    return output.split("\n");
}

void CommandEngine::cleanup()
{
    delete QObject::sender();
}
