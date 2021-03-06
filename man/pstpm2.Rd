\name{pstpm2}
\Rdversion{1.1}
\alias{pstpm2}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Flexible semi-parametric survival model.
}
\description{
This implements a penalised Royston-Parmar model using generalized
additive models.
}
\usage{
pstpm2 <- function(formula, data,
                     logH.args = NULL, logH.formula = NULL,
                     tvc = NULL, tvc.formula = NULL,
                     control = list(parscale = 0.1, maxit = 300), init = FALSE,
                     coxph.strata = NULL, weights = NULL, robust = FALSE, baseoff = FALSE,
                     bhazard = NULL, timeVar = NULL, sp=NULL, use.gr = TRUE,
                     contrasts = NULL, subset = NULL, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{formula}{
a formula object, with the response on the left of a \code{~} operator, and
the parametric terms on the right.  The response must be a survival object as
returned by the \code{\link{Surv}} function. [required]
}
  \item{data}{
a data.frame in which to interpret the variables named in
the \code{formula} argument.
}
  \item{logH.args}{
a list describing the arguments for the \code{s} function for modelling
the baseline log-cumulative hazard (default=NULL). 
}
  \item{logH.formula}{
a \code{mgcv::gam} formula for describing the baseline log-cumulative hazard function
(default=NULL). Only one of \code{df}, \code{logH.args} or
\code{logH.formula} is required. The default model is equal to \code{s(log(time),k=-1)}.
}
  \item{tvc}{
a list with the names of the time-varying coefficients.
}
  \item{tvc.formula}{
a formula for describing the time-varying coefficients. If a
time-varying coefficient is being model, then only one of
\code{tvc} and \code{tvc.formula} is required.
}
  \item{bhazard}{
a vector for the background hazard for relative survival estimation. At
present, this does not use \code{data}. At present, this is required for
all individuals - although it is only used at the event times.
}
\item{control}{\code{control} argument passed to \code{optim}.}
\item{init}{\code{init} should either be \code{FALSE}, such that initial
                  values will be determined using Cox regression, or a numeric
                  vector of initial values.}
\item{coxph.strata}{variable in the \code{data} argument for
  stratification of the \code{coxph} model fit for estimating initial values.}
\item{weights}{an optional vector of 'prior weights' to be used in the
  fitting process. Should be \code{NULL} or a numeric vector.}
\item{robust}{Boolean used to determine whether to use a robust variance
  estimator.}
\item{baseoff}{Boolean used to determine whether fully define the model
using \code{tvc.formula} rather than combining \code{logH.formula} and \code{tvc.formula}}
\item{bhazard}{variable for the baseline hazard for relative survival}
\item{timeVar}{variable defining the time variable. By default, this is
determined from the survival object, however this may be ambiguous if
two variables define the time}
\item{time0Var}{variable defining the entry time variable. By default, this is
determined from the survival object, however this may be ambiguous if
two variables define the entry time}
\item{use.gr}{Boolean to determine whether to use the gradient in the optimisation}
\item{contrasts}{an optional list. See the \code{contrasts.arg}
    of \code{\link{model.matrix.default}}.
}
\item{subset}{an optional vector specifying a subset of observations to be used in the fitting process.}
\item{\dots}{
  additional arguments to be passed to the \code{\link{mle2}} .
}
}
\details{
  
  
  The implementation extends the \code{mle2} object from the
  \code{bbmle} package.
}
\value{
A \code{pstpm2-class} object. 
  %%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
data(brcancer)
## standard Kaplan-Meier curves by hormon
plot(survfit(Surv(rectime/365,censrec==1)~1,data=brcancer,subset=hormon==1),
  xlab="Recurrence free survival time (years)",
  ylab="Survival")
lines(survfit(Surv(rectime/365,censrec==1)~1,data=brcancer,subset=hormon==0),col=2,
  conf.int=TRUE)
legend("topright", legend=c("Hormonal therapy","No hormonal therapy"),lty=1,col=1:2,bty="n")

## now fit a penalised stpm2 model
fit <- pstpm2(Surv(rectime/365,censrec==1)~hormon,data=brcancer)
## no S4 generic lines() method: instead, use plot(..., add=TRUE)
plot(fit,newdata=data.frame(hormon=1),type="surv",add=TRUE,ci=FALSE,line.col="blue",lwd=2,
  rug=FALSE)
plot(fit,newdata=data.frame(hormon=0),type="surv",add=TRUE,ci=FALSE,line.col="green",lwd=2,
  rug=FALSE)

## plot showing proportional hazards
plot(fit,newdata=data.frame(hormon=1),type="hazard",line.col="blue",lwd=2,
  rug=FALSE,ylim=c(0,1e-3))
plot(fit,newdata=data.frame(hormon=0),type="hazard",add=TRUE,ci=FALSE,line.col="green",lwd=2,
  rug=FALSE)

## tvc
fit.tvc <- pstpm2(Surv(rectime/365,censrec==1)~hormon,
  data=brcancer,
  tvc.formula=~s(log(rectime/365),by=hormon,sp=1e-3),
  coxph.strata=hormon)
anova(fit,fit.tvc)
## fit.tvc2 <- stpm2(Surv(rectime/365,censrec==1)~hormon,data=brcancer,df=5,tvc=list(hormon=3))
plot(fit.tvc,newdata=data.frame(hormon=1),type="hazard",line.col="blue",lwd=2,
  rug=FALSE,ylim=c(0,1e-3))
plot(fit.tvc,newdata=data.frame(hormon=0),type="hazard",line.col="red",lwd=2,
  rug=FALSE,add=TRUE,ci=FALSE)


## specify the smoothing parameter
fit.sp <- pstpm2(Surv(rectime/365,censrec==1)~hormon,data=brcancer,sp=fit@gam$sp*100)
plot(fit,newdata=data.frame(hormon=1),type="hazard",line.col="blue",lwd=2,
  rug=FALSE,ylim=c(0,1e-3))
plot(fit.sp,newdata=data.frame(hormon=1),type="hazard",line.col="orange",lwd=2,
  rug=FALSE,add=TRUE,ci=FALSE,lwd=2)

## compare with df=5 from stpm2
fit.stpm2 <- stpm2(Surv(rectime/365,censrec==1)~hormon,data=brcancer,df=7)
plot(fit,newdata=data.frame(hormon=1),type="hazard",line.col="blue",lwd=2,
  rug=FALSE,ylim=c(0,1e-3))
plot(fit.stpm2,newdata=data.frame(hormon=1),type="hazard",line.col="orange",lwd=2,
  rug=FALSE,add=TRUE,ci=FALSE,lwd=2)

## time-varying coefficient
summary(fit.tvc <- pstpm2(Surv(rectime,censrec==1)~hormon,data=brcancer,
                     tvc=list(hormon=3)))
anova(fit,fit.tvc) # compare with and without tvc

## some more plots
plot(fit.tvc,newdata=data.frame(hormon=0),type="hr",var="hormon")
                                        # no lines method: use add=TRUE
plot(fit.tvc,newdata=data.frame(hormon=1),type="hr",var="hormon",
     add=TRUE,ci=FALSE,line.col=2)

plot(fit.tvc,newdata=data.frame(hormon=0),type="sdiff",var="hormon")

plot(fit.tvc,newdata=data.frame(hormon=0),type="hdiff",var="hormon")

plot(fit.tvc,newdata=data.frame(hormon=0),type="hazard")
plot(fit.tvc,newdata=data.frame(hormon=1),type="hazard",line.col=2,ci=FALSE,add=TRUE)

## compare number of knots
hormon0 <- data.frame(hormon=0)
plot(fit,type="hazard",newdata=hormon0)
AIC(fit)
for (df in 4:6) {
    fit.new <- stpm2(Surv(rectime,censrec==1)~hormon,data=brcancer,df=df)
    plot(fit.new,type="hazard",newdata=hormon0,add=TRUE,ci=FALSE,line.col=df)
    print(AIC(fit.new))
}


}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%%\keyword{ ~kwd1 }
%%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
