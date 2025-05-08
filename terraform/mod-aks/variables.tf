variable "resource_group_name" {
  type        = string
  description = "AKS가 배포뵐 리소스 그룹 이름"
}
variable "resource_group_location" {
  type        = string
  description = "AKS가 배포될 리소스 그룹의 Azure 지역"
}

variable "cluster_name" {
  type        = string
  description = "클러스터 이름"
}
variable "subnet_id" {
  type        = string
  description = "AKS가 사용할 Subnet ID"
}
variable "k8s_version" {
  type        = string
  description = "쿠버네티스 버전 지정"
}
variable "identity_role_scope" {
  type = string
  description = "AKS Identity의 권한 할당 범위 - AKS 하위 리소스 컨트롤을 위함"
}

# ACR
variable "acr_name" {
  type        = string
  description = "ACR 이름"
}


