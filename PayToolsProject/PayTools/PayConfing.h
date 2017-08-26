//
//  PayConfing.h
//  PayToolsProject
//
//  Created by apple on 2017/3/29.
//  Copyright © 2017年 gupeng. All rights reserved.
//

#ifndef PayConfing_h
#define PayConfing_h

// app的回调URLScheme
#define APP_SchemeStr @"payToolsProject"
/**************************** 微信相关  ******************************/

//微信创建的 appId
#define WX_APP_ID @"wx0fa697d46acd9c33"
//微信商户id
#define WX_PARTNER_ID @"1245036702"
/**微信商户私钥(32位)*/
#define WX_PRIVATE_KEY @"75acc418324e1096dd54acfdc9d6da0c"

/**************************** 支付宝配置相关  ******************************/

/**支付宝分配给开发者的应用ID(如2014072300007148)*/
#define AL_APP_ID @"2014072300007148"
/** 签约的支付宝账号对应的支付宝唯一用户号，以2088开头的16位纯数字组成*/
#define AL_Pid  @"2048392832492324";

/**收款支付宝用户ID。 如果该值为空，则默认为商户签约账号对应的支付宝用户ID (如 2088102147948060)*/
#define SellerID @"2088911513001102"

/** 商户RSA私钥，自助生成 */
#define RSAPartnerPrivKey @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAOTvRgWZraiuxZd48X4a64cl82cCKjRsLjN7JTNfTXJ+NNlKm7ipIsKuwQFOhId8gnF1XEcQFXbKtmym4fErvjrcU7glAXGaH/J10n8kArmpdoL6ntJhEJlj6whro37t4wbsVBRG/2mMvW8aT3TsSJ8MW5E4psbT6DHV6UA3SVdxAgMBAAECgYEAxV63+poMSrIqrbVaVcL1rbV9TCBkrH9bsYyIfOq8BWpjO7aD3EcNLdSllu/PeFNSzmhE3wsxxhFsBu41OsvgmpLtZMaEmEuSs5kmMZbgS6VgAYZBgu1zgRGY/XhuwCY7WWmG/58DFv0RQG5vRNwiECuyIrz079anejXZHLMnhAUCQQDyaY9ZRLoIBD6rk78+uochA0ALqfRK3XsXWoEPvpKUGHQ6UKjdORQ3LFvgIj/90dYXL9EiIb/OI3yDuXfjHEArAkEA8cRRlVZsh4GFDx7DPl+dfsvmV+tFL/cEqtfXFSgsMz6mzv24E2rPLaYARFKW/w+epRA1qOHvL/aSRepgNlNc0wJBAML+MIYBJ5d9OqAvh73AsyPWBnWbb1utTu9ZKMnuZN/lz9B8w2i4Gk/LSdhAFLNqUEl0eEh5V11M5ELdNNemCOMCQCuF4gH2WvdR87gzG4bhA6NN5ZuyOPRXjbmLvaaLYtmez7y3pCmqsr1PAwFJtPEZyL+CWYablcmWo+J+PO/Ktg0CQHgCL44bX4Zb8xNMy2QhSMeHxTM3wOyCSWg5RGRDJmeor11Pn/sh2Lm5GHmTgVOQ0GRGsCUcFtfXtk7VvP+adkI="

/*    银联测试账号
 招商银行借记卡：6226 0900 0000 0048
     手机号：18100000000
     密码：111101
     短信验证码：123456（先点获取验证码之后再输入）
 
 华夏银行贷记卡：6226388000000095
     手机号：18100000000
     cvn2：248
     有效期：1219
     短信验证码：123456（先点获取验证码之后再输入）
     证件类型：01身份证
     证件号：510265790128303
     姓名：张三
 
 */

#endif /* PayConfing_h */
