class InvalidResponseException{
  String customMessage;
  Error innerException;

  @override
  String toString(){
    return customMessage ??= innerException.toString();
  }

  InvalidResponseException(this.innerException, {this.customMessage}){
    assert(innerException!=null);
  }
}